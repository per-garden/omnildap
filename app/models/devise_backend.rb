class DeviseBackend < Backend
  after_initialize :init

  private

  def init
    self.host = 'localhost'
  end
end
