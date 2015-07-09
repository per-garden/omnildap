module Omnildap
  class LdapOperation < LDAP::Server::Operation

    class << self
      attr_reader :basedn
    end

    def initialize(connection, messageID, hash = {})
      super(connection, messageID)
      @basedn = Rails.application.config.ldap_basedn
      @hash = hash
      User.all.each do |u|
        entry = {}
        entry['cn'] = u.name
        entry['mail'] = u.email
        @hash["cn=#{u.name},#{@basedn}"] = entry
      end
    end

    def simple_bind(version, dn, password)
      if version != 3
        raise LDAP::ResultError::ProtocolError, "version 3 only"
      end
      unless (dn && dn[0])
        raise LDAP::ResultError::InappropriateAuthentication, "Missing bind credentials. Expecting name/email, password"
      else
        if dn.include?('@')
          u = User.find_by_email(dn)
        else
          u = User.find_by_name(dn)
        end
        unless u && u.admin
          raise LDAP::ResultError::InappropriateAuthentication, 'Binding user must be admin'
        end
        unless u && u.valid_password?(password)
          raise LDAP::ResultError::InvalidCredentials
        end
      end
    end
  
    def search(basedn, scope, deref, filter = [:true])
      basedn.downcase!

      # Scope base, one, sub or children, specifying base object, one-level,
      # or subtree search (children requires LDAPv3 subordinate feature extension)
      # (http://www.zytrax.com/books/ldap/ch14/#ldapsearch)
      case scope.to_i
      when 0
        # Base object
        obj = @hash[basedn]
        raise LDAP::ResultError::NoSuchObject unless obj
        send_SearchResultEntry(basedn, obj) if LDAP::Server::Filter.run(filter, obj)
      when 1
        raise LDAP::ResultError::UnwillingToPerform, "OneLevel not implemented"
      when 2
        # Subtree
        @hash.keys.each do |key|
          obj = @hash[key]
          send_SearchResultEntry(basedn, obj) if obj && LDAP::Server::Filter.run(filter, obj)
        end
      when 3
        raise LDAP::ResultError::UnwillingToPerform, "Children not implemented"
      else
        raise LDAP::ResultError::UnwillingToPerform, "Unimplemented scope. Must be base or sub."
      end
    end
  
  end
end
