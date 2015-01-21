if !$rails_rake_task
  # Start
  if `spring status`.start_with?('Spring is not running')
    `spring start`
    directory = {}
    File.open("lib/ldap/ldapdb.yaml") { |f| directory = YAML::load(f.read) }
    params = Rails.application.config.ldap_server
    params[:operation_args] = [directory]
    server = LDAP::Server.new(params)
    server.run_tcpserver
  end
  LdapServerHelper.increment

  # Stop (triggered by stopping rails app itself, i.e. ctrl-c)
  at_exit do
    # Last rails process running makes sure spring shuts down too
    if LdapServerHelper.decrement < 1
      `spring stop`
      if server
        server.stop 
      end
    end
  end
end
