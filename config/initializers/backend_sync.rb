if !$rails_rake_task
  BackendSyncWorker.perform_async
end
