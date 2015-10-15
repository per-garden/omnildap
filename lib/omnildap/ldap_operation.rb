module Omnildap
  class LdapOperation < LDAP::Server::Operation

    class << self
      attr_reader :basedn
    end

    def initialize(connection, messageID, hash = {})
      super(connection, messageID)
      @basedn = Rails.application.config.ldap_basedn
      @hash = hash
      @users = load_users
      @groups = load_groups
      @hash.merge!(@users)
      @hash.merge!(@groups)
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
          u = User.find_by_name(name)
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
        if basedn.end_with?("ou=users,#{@basedn}")
          obj = @users[basedn]
        elsif basedn.end_with?("ou=groups,#{@basedn}")
          obj = @groups[basedn]
        elsif basedn.end_with?("#{@basedn}")
          obj = @hash[basedn]
        end
        raise LDAP::ResultError::NoSuchObject unless obj
        send_SearchResultEntry(basedn, obj) if LDAP::Server::Filter.run(filter, obj)
      when 1
        raise LDAP::ResultError::UnwillingToPerform, "OneLevel not implemented"
      when 2
        # Subtree
        if basedn.end_with?("ou=users,#{@basedn}")
          hash = @users
        elsif basedn.end_with?("ou=groups,#{@basedn}")
          hash = @groups
        elsif basedn.end_with?("#{@basedn}")
          hash = @hash
        end
        raise LDAP::ResultError::NoSuchObject unless hash
        hash.keys.each do |key|
          entry = hash[key]
          if Omnildap::LdapFilter.run(filter, entry)
            if key.include?(',ou=users,')
              send_SearchResultEntry(key, entry)
            else
              send_SearchResultEntry(key, entry)
            end
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
        entry['cn'] = u.name
        entry['mail'] = u.email
        entry['samaccountname'] = u.name
        if u.groups[0]
          groups = []
          u.groups.each do |g|
            groups << "cn=#{g.name},ou=groups,#{@basedn}"
          end
          entry['memberof'] = groups
        end
        result["cn=#{u.name},ou=users,#{@basedn}"] = entry
      end
      result
    end

    def load_groups
      result = {}
      Group.all.each do |g|
        entry = {}
        entry['cn'] = g.name
        if g.users[0]
          members = []
          g.users.each do |u|
            members << "cn=#{u.name},ou=users,#{@basedn}"
          end
          entry['member'] = members
        end
        result["cn=#{g.name},ou=groups,#{@basedn}"] = entry
      end
      result
    end

  end
end
