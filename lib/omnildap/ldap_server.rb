module Omnildap
  class LdapServer
    @@server = nil
  
    def self.start
      unless @@server
        params = Rails.application.config.ldap_server
        @@server = LDAP::Server.new(params)
        @@server.run_tcpserver
        message = 'Started listening on port ' + "#{Rails.application.config.ldap_server[:port]}"
        puts  "#{Time.now.utc.iso8601} #{Process.pid} TID-#{Thread.current.object_id.to_s(36)} Omnildap::LdapServer INFO: #{message}\n" 
        `/usr/bin/touch "#{Rails.root}"/tmp/pids/sidekiq.pid` unless File.exists?("#{Rails.root}/tmp/pids/sidekiq.pid")
      end
    end
  
    def self.stop
      if @@server
        @@server.stop
        message = 'Stopped listening on port ' + "#{Rails.application.config.ldap_server[:port]}"
        puts  "#{Time.now.utc.iso8601} #{Process.pid} TID-#{Thread.current.object_id.to_s(36)} Omnildap::LdapServer INFO: #{message}\n" 
      end
    end
  end
end
