if !$rails_rake_task
  # Start
  if `spring status`.start_with?('Spring is not running')
    `spring start`
    directory = {}
    # FIXME: Ldap data to be read dynamically - not hard coded from file.
    File.open("lib/omnildap/ldapdb.yaml") { |f| directory = YAML::load(f.read) }
    params = Rails.application.config.ldap_server
    params[:operation_class] = Omnildap::LdapOperation
    params[:operation_args] = [directory]
    server = LDAP::Server.new(params)
    server.run_tcpserver
  end
  Omnildap::LdapServerCounter.increment

  # Stop (triggered by stopping rails app itself, i.e. ctrl-c)
  at_exit do
    # Last rails process running makes sure spring shuts down too
    if Omnildap::LdapServerCounter.decrement < 1
      `spring stop`
      if server
        server.stop 
      end
    end
  end
end
