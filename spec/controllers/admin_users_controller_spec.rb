require 'spec_helper'

describe Admin::UsersController do
  before do
    @any_user = FactoryGirl.build(:devise_user)
    @any_user.save!
  end

  describe "regular user GET" do
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @user = create(:devise_user)
      sign_in @user
    end

    it 'does not list users' do
      get :index, {}, {SERVER_NAME:"#{Rails.application.config.ldap_server[:host]}:#{Rails.application.config.ldap_server[:port]}/admin/users"}
      expect(response).to_not render_template('active_admin/resource/index')
    end

    it 'does not show user' do
      get :show, id: @any_user.id
      expect(response).to_not render_template('active_admin/resource/show')
    end

    it 'does not present user edit' do
      get :edit, id: @any_user.id
      expect(response).to_not render_template('active_admin/resource/edit')
    end

    it 'does not present user new' do
      get :new
      expect(response).to_not render_template('active_admin/resource/new')
    end

  end

  describe "admin user GET" do
    before do
      @request.env['devise.mapping'] = Devise.mappings[:admin]
      @admin = create(:admin)
      sign_in @admin
      @deletable_any_user = FactoryGirl.build(:devise_user)
      @deletable_any_user.save!
    end

    it 'lists users' do
      get :index, {}, {SERVER_NAME:"#{Rails.application.config.ldap_server[:host]}:#{Rails.application.config.ldap_server[:port]}/admin/users"}
      expect(response).to render_template('active_admin/resource/index')
    end

    it 'shows user' do
      get :show, id: @any_user.id
      expect(response).to render_template('active_admin/resource/show')
    end

    it 'presents user edit' do
      get :edit, id: @any_user.id
      expect(response).to render_template('active_admin/resource/edit')
    end

    it 'presents user new' do
      get :new
      expect(response).to render_template('active_admin/resource/new')
    end

    it 'deletes user' do
      id = @deletable_any_user.id
      delete :destroy, id: id
      begin
        result = User.find(id)
      rescue
        # Expecting this find to fail
      end
      expect(result).to be_nil
    end

    after do
      @deletable_any_user ? @deletable_any_user.destroy : nil
    end
  end

  after do
    @any_user.destroy
  end
end
