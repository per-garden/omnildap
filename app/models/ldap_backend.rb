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
          Timeout::timeout("#{Rails.application.config.ldap_backend_timeout}".to_i) { backend_users = @ldap.search(base: base, filter: "(objectClass=inetOrgPerson)") }
        rescue
          Rails.logger.warn("Backend timeout on #{self.class.name}: #{self.name_string}")
        end
        backend_users.each do |bu|
          result << User.new(name: bu[:cn][0], email: bu[:mail][0], backends: [self])
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
    # Fully qualified dn unless admin or already qualified
    unless name == self.admin_name || name.split(',')[0].split('=')[1]
      name = "cn=#{name},#{self.base}"
    end
    begin
      @ldap.authenticate(name, password) ? @ldap.bind : false
    rescue
      message = "Unable to authenticate with backend #{name_string}"
      puts  "#{Time.now.utc.iso8601} #{Process.pid} TID-#{Thread.current.object_id.to_s(36)} Omnildap::LdapServer INFO: #{message}\n"
    end
  end

  private

  def init
    super
    self.host ||= 'localhost'
    self.port ||= 10389
    @ldap = Net::LDAP.new(host: host, port: port, base: base)
  end

  def admin_authenticate
    authenticate(admin_name, admin_password)
  end
end
