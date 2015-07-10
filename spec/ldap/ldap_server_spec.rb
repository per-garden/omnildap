require 'spec_helper'
require 'sidekiq/testing'

describe Omnildap::LdapServer do
  before do
    @user = FactoryGirl.build(:user)
    @user.save!
    @admin = FactoryGirl.build(:admin)
    @admin.save!
    Sidekiq::Testing.inline! do
      LdapWorker.prepare
      LdapWorker.perform_async
    end
    @client = Net::LDAP.new
    @client.port = Rails.application.config.ldap_server[:port]
  end

  describe "when receiving bind request it" do
    it "responds with Inappropriate Authentication if anonymous" do
      @client.bind.should be_falsey
      @client.get_operation_result.code.should == 48
    end

    it "responds with Inappropriate Authentication if not admin" do
      @client.authenticate(@user.name, @user.password)
      @client.bind.should be_falsey
      @client.get_operation_result.code.should == 48
    end

    it "responds with Invalid Credentials if admin credentials are incorrect" do
      @client.authenticate(@admin.name, 'not_' + @admin.password)
      @client.bind.should be_falsey
    end

    it "responds with bind result error if admin does not exist" do
      @client.authenticate('not_' + @admin.name, @admin.password)
      # Expecting Net::LDAP::NoBindResultError
      @client.get_operation_result.code.should == 0
    end

    it "responds affirmatively if admin, and correct correct credentials" do
      @client.authenticate(@admin.name, @admin.password)
      @client.bind.should be_truthy
    end

  end

  after do
    @user.destroy
    @admin.destroy
  end
end
