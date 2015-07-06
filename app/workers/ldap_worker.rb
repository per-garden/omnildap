class LdapWorker
  include Sidekiq::Worker

  def perform
    Omnildap::LdapServer.start
  end
end
