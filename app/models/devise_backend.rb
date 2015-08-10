class DeviseBackend < Backend
  acts_as_singleton
  after_initialize :init

  def find_users
    blocked ? [] : User.all.select { |u| u.email.match(/#{email_pattern}/)}
  end

  def authenticate(name, password)
    u = (find_users.select { |u| u.name == name })[0]
    u && u.valid_password?(password)
  end

  private

  def init
    self.email_pattern ||= '.*@.*'
    host = 'localhost'
  end
end
