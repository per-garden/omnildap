require 'spec_helper'
require 'sidekiq/testing'

describe Omnildap::LdapServer do
  before(:all) do
    @devise_backend = DeviseBackend.instance
    @devise_backend.name = Faker::Company.name
    @devise_backend.save!
    @admin = FactoryGirl.build(:admin)
    @admin.backends << @devise_backend
    @admin.save!
    Sidekiq::Testing.inline! do
      LdapWorker.prepare
      LdapWorker.perform_async
    end
    @client = Net::LDAP.new
    @client.port = Rails.application.config.ldap_server[:port]
  end
  
  describe 'using devise backend' do
    before(:all) do
      @user = FactoryGirl.build(:user)
      @user.backends << @devise_backend
      @user.save!
      @blocked_user = FactoryGirl.build(:blocked_user)
      @blocked_user.backends << @devise_backend
      @blocked_user.save!
    end

    describe "when receiving bind request it" do
      it "responds with Inappropriate Authentication if anonymous" do
        # @client.bind.should be_falsey
        @client.get_operation_result.code.should == 49
      end

      it "passes authentication for existing user based on name" do
        @client.authenticate("#{@user.name}", "#{@user.password}")
        @client.bind.should be_truthy
      end

      it "passes authentication for existing user based on email" do
        @client.authenticate("#{@user.email}", "#{@user.password}")
        @client.bind.should be_truthy
      end

      it "fails authentication for non-existing user" do
        @client.authenticate("not_#{@user.name}", "#{@user.password}")
        @client.bind.should be_falsey
      end

      it "fails authentication with invalid credentials" do
        @client.authenticate("#{@user.name}", "not_#{@user.password}")
        @client.bind.should be_falsey
      end

      it "fails authentication for blocked user" do
        @client.authenticate("#{@blocked_user.name}", "#{@blocked_user.password}")
        @client.bind.should be_falsey
      end
    end

    describe 'when backend blocked' do
      before do
        @devise_backend.blocked = true
        @devise_backend.save!
      end

      it "fails authentication" do
        @client.authenticate("#{@user.name}", "#{@user.password}")
        @client.bind.should be_falsey
      end

      after do
        @devise_backend.blocked = false
        @devise_backend.save!
      end
    end

    describe 'with blocking email pattern' do
      before do
        @devise_backend.email_pattern = @user.email.gsub(/.*@/, '.*@not_')
        @devise_backend.save!
      end

      it "fails authentication for user not matching pattern" do
        @client.authenticate("#{@user.name}", "#{@user.password}")
        @client.bind.should be_falsey
      end

      after do
        @devise_backend.email_pattern = '.*@.*'
        @devise_backend.save!
      end
    end
  end

  describe 'using ldap backend' do
    before(:all) do
      @ldap_backend_user = FactoryGirl.build(:user)
      @ldap_backend = FactoryGirl.build(:ldap_backend)
      @ldap_backend.save!
      @server = FakeLDAP::Server.new(port: @ldap_backend.port, base: @ldap_backend.base)
      @server.run_tcpserver
      @server.add_user("#{@ldap_backend.admin_name}" ,"#{@ldap_backend.admin_password}", 'ldap_backend_admin@ldap_backend.name')
      @server.add_user("cn=#{@ldap_backend_user.name},#{@ldap_backend.base}" ,"#{@ldap_backend_user.password}", "#{@ldap_backend_user.email}")
      # TODO: Make filtering work properly
      @filter = Net::LDAP::Filter.eq( :objectclass, '*' )
      Sidekiq::Testing.inline! do
        BackendSyncWorker.perform_async
      end
    end

    describe "when receiving bind request it" do
      it "passes authentication for existing user based on name or email" do
        @client.authenticate("#{@ldap_backend_user.name}", "#{@ldap_backend_user.password}")
        @client.bind.should be_truthy
      end

      it "passes authentication for existing user based on email" do
        @client.authenticate("#{@ldap_backend_user.email}", "#{@ldap_backend_user.password}")
        @client.bind.should be_truthy
      end

      it "fails authentication for non-existing user" do
        @client.authenticate("not_#{@ldap_backend_user.name}", "#{@ldap_backend_user.password}")
        @client.bind.should be_falsey
      end

      it "fails authentication with invalid credentials" do
        @client.authenticate("#{@ldap_backend_user.name}", "not_#{@ldap_backend_user.password}")
        @client.bind.should be_falsey
      end
    end

    it 'finds backend user based on cn' do
      @client.authenticate(@admin.name, @admin.password)
      @client.bind.should be_truthy
      base = "#{Rails.application.config.ldap_basedn}"
      entries = @client.search(base: base, filter: @filter)
      result = []
      entries.each do |e|
        result << e[:cn][0]
      end
      # expect(result).to include("cn=#{@ldap_backend_user.name},#{@ldap_backend.base}")
      expect(result).to include("#{@ldap_backend_user.name}")
    end

    it "finds backend user based on email" do
      @client.authenticate(@admin.name, @admin.password)
      @client.bind.should be_truthy
      base = "#{Rails.application.config.ldap_basedn}"
      entries = @client.search(base: base, filter: @filter)
      result = []
      entries.each do |e|
        result << e[:mail][0]
      end
      expect(result).to include("#{@ldap_backend_user.email}")
    end

    describe 'when backend blocked' do
      before do
        @ldap_backend.blocked = true
        @ldap_backend.save!
      end

      it "fails authentication" do
        @client.authenticate("#{@ldap_backend_user.name}", "#{@ldap_backend_user.password}")
        @client.bind.should be_falsey
      end

      after do
        @ldap_backend.blocked = false
        @ldap_backend.save!
      end
    end

    describe 'with blocking email pattern' do
      before do
        @ldap_backend.email_pattern = @ldap_backend_user.email.gsub(/.*@/, '.*@not_')
        @ldap_backend.save!
      end

      it "fails authentication for user not matching pattern" do
        @client.authenticate("#{@ldap_backend_user.name}", "#{@ldap_backend_user.password}")
        @client.bind.should be_falsey
      end

      after do
        @ldap_backend.email_pattern = '.*@.*'
        @ldap_backend.save!
      end
    end

    after(:all) do
      @server.stop
    end
  end

  after(:all) do
    # So why the heck doesn't database_cleaner work? Yacc!
    User.destroy_all
    Backend.destroy_all
  end
end
