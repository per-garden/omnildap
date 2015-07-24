require 'spec_helper'

describe BackendsController do

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
  end

  describe "admin user GET" do
    before do
      @request.env['devise.mapping'] = Devise.mappings[:admin]
      @admin = create(:admin)
      sign_in @admin
    end

    it 'lists backends' do
      get :index, {}, {SERVER_NAME:'localhost:3003/backends'}
      response.should render_template('backends/index')
    end

    it 'shows devise backend' do
      get :show, id: DeviseBackend.instance.id
      response.should render_template('backends/show')
    end
  end
end
