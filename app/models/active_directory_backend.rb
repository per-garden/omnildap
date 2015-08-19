class ActiveDirectoryBackend < LdapBackend

  # LDAP objectClass of which to retreive users as instances
  @@FILTER = "(objectClass=organizationalPerson)"

  private

  def backend_user_name(bu)
    bu[:samaccountname][0].split(',')[0].split('=')[1] || bu[:samaccountname][0]
  end

  def backend_user_cn(bu)
    # Nonsense voodoo to be overridden by ActiveDirectoryBackend
    name = backend_user_name(bu)
    unless name == self.admin_name || name.split(',')[0].split('=')[1]
      # Some idiots use non ASCII-8BIT characters and separators in CN!
      s = bu[0][:dn][0].force_encoding('UTF-8')
      s.gsub!(/\\,/, ',')
      # Everything between first "=" and base is cn
      cn = s.split(base)[0].split('=')[1].split(',').join(',')
      # Feed the idiots using non ASCII-8BIT characters and separators in CN!
      cn.gsub!(/,/, "\\,")
    end
  end

  def backend_user_dn(name)
    unless name == self.admin_name || name.split(',')[0].split('=')[1]
      # Some idiots use non ASCII-8BIT characters and separators in CN!
      s = bu[0][:dn][0].force_encoding('UTF-8')
      s.gsub!(/\\,/, ',')
      # Everything between first "=" and base is cn
      cn = s.split(base)[0].split('=')[1].split(',').join(',')
      # Feed the idiots using non ASCII-8BIT characters and separators in CN!
      cn.gsub!(/,/, "\\,")
      'cn=' + cn + ',' + base
    end
  end
end
