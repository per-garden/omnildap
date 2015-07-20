class DeviseBackend < Backend
  after_initialize :init

  def find_users
    blocked ? [] : User.all.select { |u| u.email.match(/#{email_pattern}/)}
  end

  def authenticate(name, password)
    u = User.find_by_name(name)
    u && u.valid_password?(password)
  end

  private

  def init
    self.host = 'localhost'
  end
end
