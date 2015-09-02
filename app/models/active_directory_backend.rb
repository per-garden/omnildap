class ActiveDirectoryBackend < LdapBackend

  private

  def backend_auth_name(name)
    # Drop qualified dn and append domain unless admin
    unless name == self.admin_name || name.split(',')[0].split('=')[1]
      # TODO: Configurable in AD-backend - not hard-coded!
      domain = 'CORPUSERS.NET'
      name = name + "@#{domain}"
    end
    name
  end

  def init
    super
    self.filter = "(mail=*)"
    @ldap = Net::LDAP.new(host: host, port: port, base: base)
  end

  def backend_user_name(bu)
    bu[:samaccountname][0].split(',')[0].split('=')[1] || bu[:samaccountname][0]
  end
end
