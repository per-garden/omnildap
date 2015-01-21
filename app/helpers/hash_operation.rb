require 'ldap/server'

# We subclass the Operation class, overriding the methods to do what we need

class HashOperation < LDAP::Server::Operation
  def initialize(connection, messageID, hash)
    super(connection, messageID)
    @hash = hash   # an object reference to our directory data
  end

  def search(basedn, scope, deref, filter)
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

  def add(dn, av)
    dn.downcase!
    raise LDAP::ResultError::EntryAlreadyExists if @hash[dn]
    @hash[dn] = av
  end

  def del(dn)
    dn.downcase!
    raise LDAP::ResultError::NoSuchObject unless @hash.has_key?(dn)
    @hash.delete(dn)
  end

  def modify(dn, ops)
    entry = @hash[dn]
    raise LDAP::ResultError::NoSuchObject unless entry
    ops.each do |attr, vals|
      op = vals.shift
      case op 
      when :add
        entry[attr] ||= []
        entry[attr] += vals
        entry[attr].uniq!
      when :delete
        if vals == []
          entry.delete(attr)
        else
          vals.each { |v| entry[attr].delete(v) }
        end
      when :replace
        entry[attr] = vals
      end
      entry.delete(attr) if entry[attr] == []
    end
  end
end
