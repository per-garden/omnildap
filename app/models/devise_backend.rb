class DeviseBackend < Backend
  validates_absence_of :port, :base
  after_initialize :init

  private

  def init
    self.host = 'localhost'
  end
end
