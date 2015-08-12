require 'spec_helper'

describe BackendsController do
  before do
    @ldap_backend = FactoryGirl.build(:ldap_backend)
    @ldap_backend.save!
  end

  describe "regular user GET" do
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @user = create(:user)
      sign_in @user
    end

    it 'does not list backends' do
      get :index, {}, {SERVER_NAME:'localhost:3003/backends'}
      response.should_not render_template('backends/index')
    end

    it 'does not show devise backend' do
      get :show, id: DeviseBackend.instance.id
      response.should_not render_template('backends/show')
    end

    it 'does not show ldap backend' do
      get :show, id: @ldap_backend.id
      response.should_not render_template('backends/show')
    end

    it 'does not present devise backend edit' do
      get :edit, id: DeviseBackend.instance.id
      response.should_not render_template('backends/edit')
    end

    it 'does not present ldap backend edit' do
      get :edit, id: @ldap_backend.id
      response.should_not render_template('backends/edit')
    end

    it 'does not present devise backend new' do
      get :new, type: 'DeviseBackend'
      response.should_not render_template('backends/new')
    end

    it 'does not present ldap backend new' do
      get :new, type: 'LdapBackend'
      response.should_not render_template('backends/new')
    end
  end

  describe "admin user GET" do
    before do
      @request.env['devise.mapping'] = Devise.mappings[:admin]
      @admin = create(:admin)
      sign_in @admin
      @deletable_ldap_backend = FactoryGirl.build(:ldap_backend)
      @deletable_ldap_backend.save!
    end

    it 'lists backends' do
      get :index, {}, {SERVER_NAME:'localhost:3003/backends'}
      response.should render_template('backends/index')
    end

    it 'shows devise backend' do
      get :show, id: DeviseBackend.instance.id
      response.should render_template('backends/show')
    end

    it 'shows ldap backend' do
      get :show, id: @ldap_backend.id
      response.should render_template('backends/show')
    end

    it 'presents devise backend edit' do
      get :edit, id: DeviseBackend.instance.id
      response.should render_template('backends/edit')
    end

    it 'presents ldap backend edit' do
      get :edit, id: @ldap_backend.id
      response.should render_template('backends/edit')
    end

    it 'presents devise backend new' do
      get :new, type: 'DeviseBackend'
      response.should render_template('backends/new')
    end

    it 'presents ldap backend new' do
      get :new, type: 'LdapBackend'
      response.should render_template('backends/new')
    end

    it 'deletes ldap backend' do
      id = @deletable_ldap_backend.id
      delete :destroy, id: id
      begin
        result = Backend.find(id)
      rescue
        # This find should fail
      end
      expect(result).to be_nil
    end

    after do
      @deletable_ldap_backend ? @deletable_ldap_backend.destroy : nil
    end
  end

  after do
    @ldap_backend.destroy
  end
end
