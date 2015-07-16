class DeviseBackend < Backend
  after_initialize :init

  def find_users
    users = []
    User.all.each do |u|
      entry = {}
      entry[:dn] = [u.name]
      entry[:cn] = [u.name]
      entry[:mail] = [u.email]
      users << entry
    end
    users
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
