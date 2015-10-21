require 'spec_helper'

describe HomeController do
  describe "GET" do

    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:user]
    end

    it 'lets user log in' do
      user = create(:devise_user)
      sign_in user
      get :index, {}, {SERVER_NAME:"#{Rails.application.config.ldap_server[:host]}:#{Rails.application.config.ldap_server[:port]}"}
      expect(response).to render_template('home/index')
    end
  end
end
