class LdapWorker
  include Sidekiq::Worker

  def self.prepare
    if `spring status`.start_with?('Spring is not running')
      `spring start`
    end
    unless File.exists?("#{Rails.root}/tmp/pids/sidekiq.pid")
     Thread.new {`bundle exec sidekiq -e "#{Rails.env}" -P "#{Rails.root}"/tmp/pids/sidekiq.pid $@ >> "#{Rails.root}"/log/sidekiq.log 2>&1`}
    end
  end

  def perform
    Omnildap::LdapServer.start
  end
end
