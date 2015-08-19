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
    result = []
    unless blocked
      if admin_authenticate
        backend_users = []
        begin
          Timeout::timeout("#{Rails.application.config.ldap_backend_timeout}".to_i) { backend_users = @ldap.search(base: base, filter: filter) }
        rescue
          Rails.logger.warn("Backend timeout on #{self.class.name}: #{self.name_string}")
        end
        # Remove local user if no longer exists on backend
        to_be_deleted = []
        self.users.each do |lu|
          (backend_users.select {|bu| bu[:mail][0] == lu.email}).empty? ? to_be_deleted << lu : nil
        end
        to_be_deleted.each do |du|
          self.users.delete(du)
          du.destroy! if du.backends.empty?
          self.save!
        end
        # Add users from backend unless already exists
        backend_users.each do |bu|
          bu_mail = bu[:mail][0]
          u = User.find_by_email(bu_mail)
          if u
            unless self.users.include?(u)
              u.backends << self
              u.save!
            end
          else
            password = Faker::Lorem.characters(9)
            # Backend user name may be fully qualified dn
            bu_name = backend_user_name(bu)
            bu_cn = backend_user_cn(bu)
            begin
              result << User.create!(name: bu_name, email: bu_mail, password: password, password_confirmation: password, cn: bu_cn, backends: [self])
            rescue
              #FIXME: This shouldn't happen
            end
          end
        end
      end
    end
    result.select { |u| u.email.match(/#{email_pattern}/)}
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
      name = backend_user_dn(name)
      begin
        @ldap.authenticate(name, password) ? @ldap.bind : false
      rescue
        message = "Unable to authenticate with backend #{name_string}"
        puts  "#{Time.now.utc.iso8601} #{Process.pid} TID-#{Thread.current.object_id.to_s(36)} Omnildap::LdapServer INFO: #{message}\n"
      end
    end
  end

  private

  def init
    super
    self.host ||= 'localhost'
    self.port ||= 10389
    # LDAP objectClass of which to retreive users as instances
    self.filter ||= "(objectClass=inetOrgPerson)"
    @ldap = Net::LDAP.new(host: host, port: port, base: base)
  end

  def admin_authenticate
    authenticate(admin_name, admin_password)
  end

  def backend_user_name(bu)
    # Backend user name may be fully qualified dn
    bu[:cn][0].split(',')[0].split('=')[1] || bu[:cn][0]
  end

  def backend_user_cn(bu)
    # Nonsense voodoo to be overridden by ActiveDirectoryBackend
    backend_user_name(bu)
  end

  def backend_user_dn(name)
    # Fully qualified dn unless admin or already qualified
    unless name == self.admin_name || name.split(',')[0].split('=')[1]
      name = "cn=#{name},#{self.base}"
    end
    name
  end
end
