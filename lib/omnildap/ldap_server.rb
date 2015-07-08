module Omnildap
  class LdapServer
    @@server = nil
  
    def self.start
      unless @@server
        params = Rails.application.config.ldap_server
        params[:operation_class] = Omnildap::LdapOperation
        @@server = LDAP::Server.new(params)
        @@server.run_tcpserver
        # ALog.debug 'Started tcp_server'
      end
    end
  
    def self.stop
      if @@server
        @@server.stop
        # ALog.debug 'Stopped tcp_server'
      end
    end
  end
end
