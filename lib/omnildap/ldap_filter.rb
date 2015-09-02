module Omnildap
  class LdapFilter < LDAP::Server::Filter
    def self.run(filter, av)
      case filter[0]
      when :eq
        # TODO: This is all we can handle for now
        av[filter[1]] == filter[3]
      else
        # FIXME: Setup not yet verified
        LDAP::Server::Filter.run(filter, av)
      end
    end
  end
end
