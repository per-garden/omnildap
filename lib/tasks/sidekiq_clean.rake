require 'rake'
require 'sidekiq/api'

# Sidekiq voodoo to clean up
# Run like: rake sidekiq:clean
namespace :sidekiq do
  task :clean => :environment do 
    Rails.cache.clear
    Sidekiq::Queue.new("default").clear
    Sidekiq::RetrySet.new.clear
    Sidekiq::ScheduledSet.new.clear
    Sidekiq::Stats.new.reset
    `redis-cli flushall`
  end
end
