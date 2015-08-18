class BackendSyncWorker
  include Sidekiq::Worker

  @@running = false

  def perform
    unless @@running
      @@running = !@@running
      BackendSync.new.sync
      @@running = !@@running
    end
  end
end
