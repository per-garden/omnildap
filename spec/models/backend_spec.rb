require 'spec_helper'
require 'sidekiq/testing'

describe Backend do
  before(:all) do
    @user = FactoryGirl.build(:devise_user)
    @user.save!
    @dual_backend_user = FactoryGirl.build(:devise_user)
    @dual_backend_user.save!
    DeviseBackend.instance.name = Faker::Company.name
    DeviseBackend.instance.save!
  end

  it "it does not have any valid factory (abstract class)" do
    begin
      b = FactoryGirl.build(:backend)
    rescue
      # Expecting this to fail
    end
    expect(b).to be_nil
  end

  describe 'using devise backend' do

    it 'does not allow duplicate user name within backend' do
      @another_user = FactoryGirl.build(:devise_user, name: @user.name)
      begin
        @another_user.save!
        DeviseBackend.instance.users << @another_user
        DeviseBackend.instance.save
      rescue
        # Expecting this to fail
      end
      expect(DeviseBackend.instance.users).not_to include(@another_user)
    end

    it 'does not allow duplicate user email within backend' do
      @another_user = FactoryGirl.build(:devise_user, email: @user.email)
      begin
        @another_user.save!
        DeviseBackend.instance.users << @another_user
        DeviseBackend.instance.save
      rescue
        # Expecting this to fail
      end
      expect(DeviseBackend.instance.users).not_to include(@another_user)
    end

    after(:each) do
      @another_user ? @another_user.destroy : nil
    end
  end

  describe 'using ldap backend' do
    before(:all) do
      @ldap_backend = FactoryGirl.build(:ldap_backend)
      @server = FakeLDAP::Server.new(port: @ldap_backend.port, base: @ldap_backend.base)
      @server.add_user("#{@ldap_backend.admin_name}" ,"#{@ldap_backend.admin_password}", 'ldap_backend_admin@ldap_backend.name')
      @server.run_tcpserver
      @ldap_backend.save!
      @user = FactoryGirl.build(:user)
      @server.add_user("cn=#{@user.name},#{@ldap_backend.base}" ,"#{@user.password}", "#{@user.email}")
      Sidekiq::Testing.inline! do
        BackendSyncWorker.perform_async
      end
      Sidekiq::Testing.inline! do
        LdapWorker.prepare
        LdapWorker.perform_async
      end
    end

    before(:each) do
      @user = FactoryGirl.build(:user)
      @server.add_user("cn=#{@user.name},#{@ldap_backend.base}" ,"#{@user.password}", "#{@user.email}")
      Sidekiq::Testing.inline! do
        BackendSyncWorker.perform_async
      end
    end

    it 'allows user to belong to several backends' do
      @server.add_user("cn=#{@dual_backend_user.name},#{@ldap_backend.base}" ,"#{@dual_backend_user.password}", "#{@dual_backend_user.email}")
      Sidekiq::Testing.inline! do
        BackendSyncWorker.perform_async
      end
      user = @dual_backend_user
      expect(LdapBackend.find(@ldap_backend.id).users).to include(@dual_backend_user)
    end

    it 'does not allow duplicate user name within backend' do
      @another_user = FactoryGirl.build(:user, name: @user.name)
      begin
        @server.add_user("cn=#{@another_user.name},#{@ldap_backend.base}" ,"#{@another_user.password}", "#{@another_user.email}")
        Sidekiq::Testing.inline! do
          BackendSyncWorker.perform_async
        end
      rescue
        # Expecting this to fail
      end
      expect(LdapBackend.find(@ldap_backend.id).users).not_to include(@another_user)
    end

    it 'does not allow duplicate user email within backend' do
      @another_user = FactoryGirl.build(:user, email: @user.email)
      begin
        @server.add_user("cn=#{@another_user.name},#{@ldap_backend.base}" ,"#{@another_user.password}", "#{@another_user.email}")
        Sidekiq::Testing.inline! do
          BackendSyncWorker.perform_async
        end
      rescue
        # Expecting this to fail
      end
      expect(LdapBackend.find(@ldap_backend.id).users).not_to include(@another_user)
    end

    after(:each) do
      @another_user ? @another_user.destroy : nil
    end

    after(:all) do
      @server.stop
      @ldap_backend ? @ldap_backend.destroy : nil
    end
  end

  after(:all) do
    User.destroy_all
    Backend.destroy_all
  end
end
