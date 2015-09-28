module Admin::BackendsHelper

  # In (e.g.) an action-item-styled drop down, reset to neutral
  def dropdown_link_style
   "color: #555; background-color: transparent; border-color: transparent;"
  end

  def type_show(type)
    case type
    when 'DeviseBackend'
      'devise_backend'
    when 'LdapBackend'
      'ldap_backend'
    when 'ActiveDirectoryBackend'
      'active_directory_backend'
    end
  end
end
