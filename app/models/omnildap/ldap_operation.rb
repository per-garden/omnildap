module Omnildap
  class LdapOperation < LDAP::Server::Operation
    def initialize(connection, messageID, hash)
      # ALog.debug 'Starting Ldap Operation'
      super(connection, messageID)
      @hash = hash
    end
  
    def search(basedn, scope, deref, filter)
      # ALog.debug 'LdapOperation doing search'
      basedn.downcase!
  
      case scope
      when LDAP::Server::BaseObject
        # client asked for single object by DN
        obj = @hash[basedn]
        raise LDAP::ResultError::NoSuchObject unless obj
        send_SearchResultEntry(basedn, obj) if LDAP::Server::Filter.run(filter, obj)
  
      when LDAP::Server::WholeSubtree
        @hash.each do |dn, av|
          next unless dn.index(basedn, -basedn.length)    # under basedn?
          next unless LDAP::Server::Filter.run(filter, av)  # attribute filter?
          send_SearchResultEntry(dn, av)
        end
  
      else
        raise LDAP::ResultError::UnwillingToPerform, "OneLevel not implemented"
  
      end
    end
  
  end
end
