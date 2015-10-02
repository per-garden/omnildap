require 'spec_helper'
require 'sidekiq/testing'

describe Backend do
  it "has a valid factory" do
    expect(DeviseBackend.instance).to be_valid
    expect(build :ldap_backend).to be_valid
    expect(build :active_directory_backend).to be_valid
  end

  describe 'using devise backend' do
    before(:each) do
      @devise_backend = DeviseBackend.instance
      @devise_backend.name = Faker::Company.name
      # User factory automatically adds ':user' to singleton DeviseBackend
      @user = FactoryGirl.build(:user)
      # Saving first user should be OK
      @user.save!
      DeviseBackend.instance.users << @user
      DeviseBackend.instance.save
    end

    it 'does not allow duplicate user name within backend' do
      @another_user = FactoryGirl.build(:user, name: @user.name)
      begin
        @another_user.save!
        DeviseBackend.instance.users << @another_user
        DeviseBackend.instance.save
      rescue
        # Expecting this to fail
      end
      # Expecting only first user to be saved
      expect(@devise_backend.users).not_to include(@another_user)
    end

    it 'does not allow duplicate user email within backend' do
      @another_user = FactoryGirl.build(:user, email: @user.email)
      begin
        @another_user.save!
        DeviseBackend.instance.users << @another_user
        DeviseBackend.instance.save
      rescue
        # Expecting this to fail
      end
      # Expecting only first user to be saved
      expect(@devise_backend.users).not_to include(@another_user)
    end

    after(:each) do
      @user ? @user.destroy : nil
      @another_user ? @another_user.destroy : nil
      @devise_backend ? @devise_backend.destroy : nil
    end
  end

  describe 'using ldap backend' do
    before(:all) do
      @ldap_backend = FactoryGirl.build(:ldap_backend)
      @server = FakeLDAP::Server.new(port: @ldap_backend.port, base: @ldap_backend.base)
      @server.add_user("#{@ldap_backend.admin_name}" ,"#{@ldap_backend.admin_password}", 'ldap_backend_admin@ldap_backend.name')
      @server.run_tcpserver
      @ldap_backend.save!
      Sidekiq::Testing.inline! do
        LdapWorker.prepare
        LdapWorker.perform_async
      end
    end

    before(:each) do
      @user = FactoryGirl.build(:ldap_user)
      # Saving first user should be OK
      @server.add_user("cn=#{@user.name},#{@ldap_backend.base}" ,"#{@user.password}", "#{@user.email}")
      # Backend sync
      Sidekiq::Testing.inline! do
        BackendSyncWorker.perform_async
      end
    end

    it 'does not allow duplicate user name within backend' do
      @another_user = FactoryGirl.build(:ldap_user, name: @user.name)
      begin
        @server.add_user("cn=#{@another_user.name},#{@ldap_backend.base}" ,"#{@another_user.password}", "#{@another_user.email}")
        # Backend sync
        Sidekiq::Testing.inline! do
          BackendSyncWorker.perform_async
        end
      rescue
        # Expecting this to fail
      end
      # Expecting only first user to be saved
      expect(@ldap_backend.users).not_to include(@another_user)
    end

    it 'does not allow duplicate user email within backend' do
      @another_user = FactoryGirl.build(:ldap_user, email: @user.email)
      begin
        @server.add_user("cn=#{@another_user.name},#{@ldap_backend.base}" ,"#{@another_user.password}", "#{@another_user.email}")
        # Backend sync
        Sidekiq::Testing.inline! do
          BackendSyncWorker.perform_async
        end
      rescue
        # Expecting this to fail
      end
      # Expecting only first user to be saved
      expect(@ldap_backend.users).not_to include(@another_user)
    end

    after(:each) do
      @user ? @user.destroy : nil
      @another_user ? @another_user.destroy : nil
    end

    after(:all) do
      @server.stop
      @ldap_backend ? @ldap_backend.destroy : nil
    end
  end
end
