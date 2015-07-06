if !$rails_rake_task
  if `spring status`.start_with?('Spring is not running')
    `spring start`
  end
  unless File.exists?("#{Rails.root}/tmp/pids/sidekiq.pid")
   # ALog.debug 'Forking off new sidekiq thread'
   Thread.new {`bundle exec sidekiq -e "#{Rails.env}" -P "#{Rails.root}"/tmp/pids/sidekiq.pid $@ >> "#{Rails.root}"/log/sidekiq.log 2>&1`}
  end
  # ALog.debug 'Ready to do LdapWorker.perform_async'
  LdapWorker.perform_async

  # Stop (triggered by stopping rails app itself, i.e. ctrl-c)
  at_exit do
    Omnildap::LdapServer.stop
    if File.exists?("#{Rails.root}/tmp/pids/sidekiq.pid")
      `bundle exec sidekiqctl stop "#{Rails.root}"/tmp/pids/sidekiq.pid >> "#{Rails.root}"/log/sidekiq.log 2>&1`
    end
    unless `spring status`.start_with?('Spring is not running')
      `spring stop`
    end
  end
end
