module Omnildap
  class LdapServer
    @@server = nil
  
    def self.start
      unless @@server
        directory = {}
        # FIXME: Ldap data to be read dynamically - not hard coded from file.
        File.open("lib/omnildap/ldapdb.yaml") { |f| directory = YAML::load(f.read) }
        params = Rails.application.config.ldap_server
        params[:operation_class] = Omnildap::LdapOperation
        params[:operation_args] = [directory]
        @@server = LDAP::Server.new(params)
        @@server.run_tcpserver
        # ALog.debug 'Started tcp_server'
        # Omnildap::LdapServerCounter.increment
      end
    end
  
    def self.stop
      if @@server
        # ALog.debug @@server
        @@server.stop
        # ALog.debug 'Stopped tcp_server'
        # Omnildap::LdapServerCounter.decrement
      end
    end
  end
end
