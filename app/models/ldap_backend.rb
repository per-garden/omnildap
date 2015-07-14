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

  def find_user_by_ldap(criteria, login)
    begin
      filter = Net::LDAP::Filter.eq(criteria,login)
      authenticate
      @ldap.search(base: "#{base}", filter: filter)
    rescue
      # TODO: Logging of backend problems
    end
  end

  private

  def init
    self.host ||= 'localhost'
    self.port ||= 10389
    @ldap = Net::LDAP.new(host: host, port: port, base: base)
  end

  def authenticate
    @ldap.authenticate(admin_name, admin_password) ? @ldap.bind : false
  end
end
