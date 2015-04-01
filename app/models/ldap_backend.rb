class LdapBackend < Backend
  # Cannot guesswork a default entry point into LDAP tree
  validates_presence_of :base
  after_initialize :init

  private

  def init
    self.host ||= 'localhost'
    self.port ||= 10389
  end
end
