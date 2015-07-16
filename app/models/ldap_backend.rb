class LdapBackend < Backend
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
    if admin_authenticate
      result = @ldap.search(base: base, filter: "(objectClass=inetOrgPerson)")
    end
    result || []
  end

  def find_groups_by_ldap
    if admin_authenticate
      result = @ldap.search(base: base, filter: "(objectClass=groupofnames)")
    end
    result || []
  end

  def authenticate(name, password)
    @ldap.authenticate(name, password) ? @ldap.bind : false
  end

  private

  def init
    self.host ||= 'localhost'
    self.port ||= 10389
    @ldap = Net::LDAP.new(host: host, port: port, base: base)
  end

  def admin_authenticate
    @ldap.authenticate(admin_name, admin_password) ? @ldap.bind : false
  end
end
