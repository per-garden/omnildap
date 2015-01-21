if !$rails_rake_task
  # Start
  directory = {}
  File.open("lib/ldap/ldapdb.yaml") { |f| directory = YAML::load(f.read) }
  params = Rails.application.config.ldap_server
  params[:operation_args] = [directory]
  server = LDAP::Server.new(params)
  server.run_tcpserver

  # Stop (triggered by stopping rails app itself, i.e. ctrl-c)
  at_exit do
    `spring stop`
    server.stop
  end
end
