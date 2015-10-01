if !$rails_rake_task
  # When testing we need to inline sidekiq
  unless Rails.env.test?
    LdapWorker.prepare
    LdapWorker.perform_async
  end

  # Stop (triggered by stopping rails app itself, i.e. ctrl-c)
  at_exit do
    Omnildap::LdapServer.stop
    if File.exists?("#{Rails.root}/tmp/pids/sidekiq.pid")
      # `bundle exec sidekiqctl stop "#{Rails.root}"/tmp/pids/sidekiq.pid >> "#{Rails.root}"/log/sidekiq.log 2>&1`
      # So why doesn't sidekiqctl work properly?
      file = File.open("#{Rails.root}/tmp/pids/sidekiq.pid", "r")
      pid = file.read.gsub(/[^0-9]/,'')
      file.close
      `kill "#{pid}" >> "#{Rails.root}"/log/sidekiq.log 2>&1`
      while  File.exists?("#{Rails.root}/tmp/pids/sidekiq.pid")
        File.delete("#{Rails.root}/tmp/pids/sidekiq.pid")
        sleep(1)
      end
    end
    silence_stream(STDERR) do
      unless `spring status`.start_with?('Spring is not running')
        `spring stop`
      end
    end
  end
end
