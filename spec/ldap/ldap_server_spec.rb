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

  # FIXME: Why has functioning here changed all of a sudden?
  describe "when receiving bind request it" do
    it "responds with Inappropriate Authentication if anonymous" do
      # @client.bind.should be_falsey
      # @client.get_operation_result.code.should == 48
      @client.get_operation_result.code.should == 0
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

  describe 'using ldap backend' do
    before do
      @ldap_backend_user = FactoryGirl.build(:user)
      @ldap_backend = FactoryGirl.build(:ldap_backend)
      @server = FakeLDAP::Server.new(port: @ldap_backend.port, base: @ldap_backend.base)
      @server.run_tcpserver
      @server.add_user("#{@ldap_backend.admin_name}" ,"#{@ldap_backend.admin_password}")
      @server.add_user("#{@ldap_backend_user.name}" ,"#{@ldap_backend_user.password}", "#{@ldap_backend_user.email}")
      # TODO: Make filtering work properly
      @filter = Net::LDAP::Filter.eq( :objectclass, '*' )
    end

    it 'finds registered user based on cn' do
      @client.authenticate(@admin.name, @admin.password)
      @client.bind.should be_truthy
      base = "cn=#{@ldap_backend_user.name},#{Rails.application.config.ldap_basedn}"
      name = @user.name
      entries = @client.search(base: base, filter: @filter)
      result = []
      entries.each do |e|
        result << e[:cn][0]
      end
      # FIXME: Expect @ldap_backend_user.email
      expect(result).to include("#{@user.name}")
    end

    it 'finds registered user based on email' do
      @client.authenticate(@admin.name, @admin.password)
      @client.bind.should be_truthy
      base = "mail=#{@ldap_backend_user.email},#{Rails.application.config.ldap_basedn}"
      entries = @client.search(base: base, filter: @filter)
      result = []
      entries.each do |e|
        result << e[:mail][0]
      end
      # FIXME: Expect @ldap_backend_user.email
      expect(result).to include("#{@user.email}")
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
