module Omnildap
  class LdapOperation < LDAP::Server::Operation

    class << self
      attr_reader :basedn
    end

    def initialize(connection, messageID, hash = {})
      super(connection, messageID)
      @basedn = Rails.application.config.ldap_basedn
      @hash = hash
      @hash.merge!(load_users)
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
          # Fully qualified dn?
          name = dn.split(',')[0].split('=')[1] || dn
          ALog.debug 'Trying find_user_by_name: ' + name
          u = User.find_by_name(name)
          ALog.debug 'Got it' if u
          u
        end
        unless u
          raise LDAP::ResultError::InvalidCredentials, 'User does not exist'
        end
        unless u && !u.blocked && u.valid_bind?(password)
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
        ALog.debug 'WTF??!!'
        # Subtree
        @hash.keys.each do |key|
          entry = @hash[key]
          if Omnildap::LdapFilter.run(filter, entry)
            ALog.debug entry
            send_SearchResultEntry("cn=#{entry['cn']}," + basedn, entry)
          end
        end
      when 3
        raise LDAP::ResultError::UnwillingToPerform, "Children not implemented"
      else
        raise LDAP::ResultError::UnwillingToPerform, "Unimplemented scope. Must be base or sub."
      end
    end
  
    private

    def load_users
      result = {}
      User.all.each do |u|
        entry = {}
        # entry['sn'] = 'Fred Flintstone'
        # entry['userpassword'] = 'gnA11arg'
        entry['cn'] = u.name
        entry['mail'] = u.email
        result["cn=#{u.name},#{@basedn}"] = entry
      end
      result
    end

  end
end
