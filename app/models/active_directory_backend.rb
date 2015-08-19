class ActiveDirectoryBackend < LdapBackend

  # LDAP objectClass of which to retreive users as instances
  @@FILTER = "(objectClass=organizationalPerson)"

  private

  def backend_user_name(bu)
    bu[:samaccountname][0].split(',')[0].split('=')[1] || bu[:samaccountname][0]
  end

  def backend_user_cn(bu)
    # Some idiots use non ASCII-8BIT characters and separators in CN!
    s = bu[0][:dn][0].force_encoding('UTF-8')
    s.gsub!(/\\,/, ',')
    # Everything between first "=" and base is cn
    cn = s.split(base)[0].split('=')[1].split(',').join(',')
    # Feed the idiots using non ASCII-8BIT characters and separators in CN!
    cn.gsub!(/,/, "\\,")
  end

  def backend_user_dn(name)
    # Fully qualified dn unless admin or already qualified
    unless name == self.admin_name || name.split(',')[0].split('=')[1]
      u = User.find_by_name(name)
      name = "cn=#{u.cn},#{self.base}"
    end
    name
  end
end
