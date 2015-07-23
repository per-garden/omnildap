require 'spec_helper'
require 'sidekiq/testing'

describe Omnildap::LdapServer do
  before do
    @devise_backend = FactoryGirl.build(:devise_backend)
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
    before do
      @user = FactoryGirl.build(:user)
      @user.backends << @devise_backend
      @user.save!
      @blocked_user = FactoryGirl.build(:blocked_user)
      @blocked_user.backends << @devise_backend
      @blocked_user.save!
    end

    describe "when receiving bind request it" do
      it "responds with Inappropriate Authentication if anonymous" do
        @client.bind.should be_falsey
        @client.get_operation_result.code.should == 48
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
        # All configured devise backends represent devise on local instance
        backends = Backend.all.select { |b| b.type == 'DeviseBackend' }
        backends.each do |b|
          b.blocked = true
          b.save!
        end
      end

      it "fails authentication" do
        @client.authenticate("#{@user.name}", "#{@user.password}")
        @client.bind.should be_falsey
      end

      after do
        backends = Backend.all.select { |b| b.type == 'DeviseBackend' }
        backends.each do |b|
          b.blocked = false
          b.save!
        end
      end
    end

    describe 'with blocking email pattern' do
      before do
        # All configured devise backends represent devise on local instance
        backends = Backend.all.select { |b| b.type == 'DeviseBackend' }
        backends.each do |b|
          b.email_pattern = @user.email.gsub(/.*@/, '.*@not_')
          b.save!
        end
      end

      it "fails authentication for user not matching pattern" do
        @client.authenticate("#{@user.name}", "#{@user.password}")
        @client.bind.should be_falsey
      end

      after do
        backends = Backend.all.select { |b| b.type == 'DeviseBackend' }
        backends.each do |b|
          b.email_pattern = '.*@.*'
          b.save!
        end
      end
    end
  end

  describe 'using ldap backend' do
    before do
      @ldap_backend_user = FactoryGirl.build(:user)
      @ldap_backend = FactoryGirl.build(:ldap_backend)
      @ldap_backend.save!
      @server = FakeLDAP::Server.new(port: @ldap_backend.port, base: @ldap_backend.base)
      @server.run_tcpserver
      @server.add_user("#{@ldap_backend.admin_name}" ,"#{@ldap_backend.admin_password}")
      @server.add_user("#{@ldap_backend_user.name}" ,"#{@ldap_backend_user.password}", "#{@ldap_backend_user.email}")
      # TODO: Make filtering work properly
      @filter = Net::LDAP::Filter.eq( :objectclass, '*' )
    end

    describe "when receiving bind request it" do
      it "passes authentication for existing user based on name" do
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

    after do
      @server.stop
    end
  end

  after do
    # So why the heck doesn't database_cleaner work? Yacc!
    User.destroy_all
    Backend.destroy_all
  end
end
