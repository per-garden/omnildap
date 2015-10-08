require 'spec_helper'

describe Admin::GroupsController do
  before do
    @group = FactoryGirl.build(:group)
    @group.save!
  end

  describe "regular user GET" do
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @user = create(:devise_user)
      sign_in @user
    end

    it 'does not list groups' do
      get :index, {}, {SERVER_NAME:'localhost:3003/admin/groups'}
      expect(response).to_not render_template('active_admin/resource/index')
    end

    it 'does not show group' do
      get :show, id: @group.id
      expect(response).to_not render_template('active_admin/resource/show')
    end

    it 'does not present group edit' do
      get :edit, id: @group.id
      expect(response).to_not render_template('active_admin/resource/edit')
    end

    it 'does not present group new' do
      get :new
      expect(response).to_not render_template('active_admin/resource/new')
    end

    after do
      @user.destroy
    end
  end

  describe "admin group GET" do
    before do
      @request.env['devise.mapping'] = Devise.mappings[:admin]
      @admin = create(:admin)
      sign_in @admin
      @deletable_group = FactoryGirl.build(:group)
      @deletable_group.save!
    end

    it 'lists groups' do
      get :index, {}, {SERVER_NAME:'localhost:3003/admin/groups'}
      expect(response).to render_template('active_admin/resource/index')
    end

    it 'shows group' do
      get :show, id: @group.id
      expect(response).to render_template('active_admin/resource/show')
    end

    it 'presents group edit' do
      get :edit, id: @group.id
      expect(response).to render_template('active_admin/resource/edit')
    end

    it 'presents group new' do
      get :new
      expect(response).to render_template('active_admin/resource/new')
    end

    it 'deletes group' do
      id = @deletable_group.id
      delete :destroy, id: id
      begin
        result = Group.find(id)
      rescue
        # Expecting this find to fail
      end
      expect(result).to be_nil
    end

    after do
      @admin.destroy
    end
  end

  after do
    Group.destroy_all
  end
end
