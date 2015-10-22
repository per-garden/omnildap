class LdapBackend < Backend
  validates_presence_of :host
  # Cannot guesswork a default entry point into LDAP tree
  validates_presence_of :base
  after_initialize :init

  def signup(email, name, password)
    ldap = Net::LDAP.new(host: host, port: port, base: base)
    ldap.authenticate("cn=#{name}," + base, password)
    if ldap.bind
      u = User.create!(email: email, name: name, password: password, password_confirmation: password)
      users << u
      save!
    end
  end

  def find_users
    unless blocked
      if admin_authenticate
        backend_users = []
        timed_out = false
        begin
          Timeout::timeout("#{Rails.application.config.ldap_backend_timeout}".to_i) { backend_users = @ldap.search(base: base, filter: filter) }
        rescue
          timed_out = true
          Rails.logger.warn("Backend timeout on #{self.class.name}: #{self.name_string}")
        end
        unless timed_out
          sync_users(backend_users)
        end
      end
    end
  end

  def find_groups_by_ldap
    if admin_authenticate
      result = @ldap.search(base: base, filter: "(objectClass=groupofnames)")
    end
    result || []
  end

  def authenticate(name, password)
    # No authentication if this backend blocked or user's email blocked with it
    unless self.blocked || email_blocked?(name.split(',')[0].split('=')[1] || name)
      name = backend_auth_name(name)
      begin
        @ldap.authenticate(name, password) ? @ldap.bind : false
      rescue
        message = "Unable to authenticate with backend #{name_string}"
        puts  "#{Time.now.utc.iso8601} #{Process.pid} TID-#{Thread.current.object_id.to_s(36)} Omnildap::LdapServer INFO: #{message}\n"
      end
    end
  end

  private

  def backend_auth_name(name)
    # Fully qualified dn unless admin or already qualified
    unless name == self.admin_name || name.split(',')[0].split('=')[1]
      name = "cn=#{name},#{self.base}"
    end
    name
  end

  def init
    super
    self.host ||= 'localhost'
    self.port ||= 10389
    # LDAP objectClass of which to retreive users as instances
    self.filter ||= "(mail=*)"
    @ldap = Net::LDAP.new(host: host, port: port, base: base)
  end

  def admin_authenticate
    authenticate(admin_name, admin_password)
  end

  def backend_user_name(bu)
    # Backend user name may be fully qualified dn
    bu[:cn][0].split(',')[0].split('=')[1] || bu[:cn][0]
  end

  def sync_users(backend_users)
    # Remove local user if no longer exists on backend
    to_be_deleted = []
    if backend_users && backend_users[0]
      self.users.each do |lu|
        (backend_users.select {|bu| (bu[:mail][0]).downcase == lu.email}).empty? ? to_be_deleted << lu : nil
        (backend_users.select {|bu| backend_user_name(bu).downcase == lu.name}).empty? ? to_be_deleted << lu : nil
      end
    else
      # Backend deleted all users
      to_be_deleted = self.users
    end
    to_be_deleted.uniq!
    to_be_deleted.each do |du|
      du.backends.delete(self)
      self.users.delete(du)
      du.destroy! if du.backends.empty?
    end
    self.save unless to_be_deleted.empty?
    if backend_users && backend_users[0]
      # Add users from backend unless already exists
      backend_users.each do |bu|
        # Backend user name may be fully qualified dn
        bu_name = backend_user_name(bu)
        bu_mail = (bu[:mail][0]).downcase
        u = User.find_by_email(bu_mail) || User.find_by_name(bu_name)
        if u
          u.backends << self unless u.backends.include?(self)
          u.name = bu_name
          u.email = bu_mail
          u.save!
        else
          password = Faker::Lorem.characters(9)
          begin
            User.create!(name: bu_name, email: bu_mail, password: password, password_confirmation: password, backends: [self])
          rescue
            #FIXME: This shouldn't happen
          end
        end
      end
    end
    self.save
  end
end
