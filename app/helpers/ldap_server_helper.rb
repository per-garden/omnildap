class LdapServerHelper
  @@count = 0

  def self.increment
    @@count = @@count + 1
  end

  def self.decrement
    @@count = @@count - 1
  end
end
