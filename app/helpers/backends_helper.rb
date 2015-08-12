module BackendsHelper

  def type_show(type)
    case type
    when 'DeviseBackend'
      'devise_backend'
    when 'LdapBackend'
      'ldap_backend'
    when 'ActiveDirectoryBackend'
      'ldap_backend'
    end
  end

  def type_form(type)
    case type
    when 'DeviseBackend'
      'devise_form'
    when 'LdapBackend'
      'ldap_form'
    when 'ActiveDirectoryBackend'
      'ldap_form'
    end
  end
end
