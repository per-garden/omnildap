require 'spec_helper'
require 'sidekiq/testing'

describe Omnildap::LdapServer do
  before do
    Sidekiq::Testing.inline! do
      LdapWorker.prepare
      LdapWorker.perform_async
    end
    @client = Net::LDAP.new
    @client.port = Rails.application.config.ldap_server[:port]
  end

  describe "when receiving a top-level bind request it" do
    it "responds with Inappropriate Authentication to anonymous bind requests" do
      @client.bind.should be_falsey
      @client.get_operation_result.code.should == 48
    end

    it "responds with Invalid Credentials if the password is incorrect" do
      skip 'TODO'
    end

    it "responds with Invalid Credentials if the user does not exist" do
      skip 'TODO'
    end

    it "responds affirmatively if the username and password are correct" do
      skip 'TODO'
    end

  end
end
