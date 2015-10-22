class ActiveDirectoryBackend < LdapBackend
  validates_presence_of :domain

  private

  def backend_auth_name(name)
    # Drop qualified dn and append domain unless admin
    unless name == self.admin_name || name.split(',')[0].split('=')[1]
      name = name + "@#{self.domain}"
    end
    name
  end

  def init
    super
    @ldap = Net::LDAP.new(host: host, port: port, base: base)
  end

  def backend_user_name(bu)
    bu[:samaccountname][0].split(',')[0].split('=')[1] || bu[:samaccountname][0]
  end
end
