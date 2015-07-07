module Omnildap
  class LdapOperation < LDAP::Server::Operation
    # @basedn = 'cn=omnildap,dc=omnildap'

    class << self
      attr_reader :basedn
    end

    def initialize(connection, messageID, hash)
      super(connection, messageID)
      @hash = hash
    end
  
    def search(basedn, scope, deref, filter)
      # ALog.debug 'Incoming basedn in search is: ' + basedn
      basedn.downcase!
      name = basedn.split(/\W+/)[1]

      case scope
      # TODO: single object how/what?
      when LDAP::Server::BaseObject
        # ALog.debug 'Client asked for single object by DN. We are now in ldap_operation.rb'
        # ALog.debug 'We use LdapOperation.basedn ' + basedn
        # ALog.debug 'to retrieve from hash:'
        # ALog.debug @hash
        # client asked for single object by DN
        obj = @hash[basedn]
        # ALog.debug "And this is what we return:"
        # ALog.debug obj
        raise LDAP::ResultError::NoSuchObject unless obj
        send_SearchResultEntry(basedn, obj) if LDAP::Server::Filter.run(filter, obj)
  
      when LDAP::Server::WholeSubtree
        u = User.find_by_name(name)
        send_SearchResultEntry(basedn, {'cn' => [u.name], 'mail' => [u.email]}) if u
  
      else
        raise LDAP::ResultError::UnwillingToPerform, "OneLevel not implemented"
  
      end
    end
  
  end
end
