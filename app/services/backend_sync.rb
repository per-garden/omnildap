class BackendSync

  def sync
    Backend.all.each do |b|
      b.find_users
    end
    interval = "#{Rails.application.config.backend_sync_interval}".to_i
    BackendSyncWorker.perform_at(Time.now + interval) unless interval == 0
  end
end
