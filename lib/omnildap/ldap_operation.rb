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
      # ALog.debug 'Scope of search is:'
      # ALog.debug scope.to_i.to_s
      basedn.downcase!
      name = basedn.split(/\W+/)[1]

      # Scope base, one, sub or children, specifying base object, one-level,
      # or subtree search (children requires LDAPv3 subordinate feature extension)
      # (http://www.zytrax.com/books/ldap/ch14/#ldapsearch)
      case scope.to_i
      when 0 #LDAP::Server::BaseObject
        # Client asked for single object by DN
        obj = @hash[basedn]
        raise LDAP::ResultError::NoSuchObject unless obj
        send_SearchResultEntry(basedn, obj) if LDAP::Server::Filter.run(filter, obj)
      when 1
        raise LDAP::ResultError::UnwillingToPerform, "OneLevel not implemented"
      when 2
        basedn = @hash.keys[0]
        obj = @hash[basedn]
        send_SearchResultEntry(basedn, obj) if LDAP::Server::Filter.run(filter, obj)
        # u = User.find_by_name(name)
        # send_SearchResultEntry(basedn, {'cn' => [u.name], 'mail' => [u.email]}) if u
      when 3
        raise LDAP::ResultError::UnwillingToPerform, "Children not implemented"
      else
        raise LDAP::ResultError::UnwillingToPerform, "Unimplemented scope. Must be base or sub."
      end
    end
  
  end
end
