require 'spec_helper'

describe HomeController do
  describe "GET" do

    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:user]
    end

    it 'lets user log in' do
      user = create(:user)
      sign_in user
      get :index, {}, {SERVER_NAME:'localhost:3003'}
      response.should render_template('home/index')
    end
  end
end
