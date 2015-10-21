require 'spec_helper'

describe Users::RegistrationsController do
  describe "GET" do

    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:user]
    end

    it 'lets user sign up' do
      get :new, {}, {SERVER_NAME:"#{Rails.application.config.ldap_server[:host]}:#{Rails.application.config.ldap_server[:port]}"}
      expect(response).to render_template('devise/registrations/new')
    end

    describe 'with blocked sign-up' do
      before do
        @devise_backend = DeviseBackend.instance
        @devise_backend.signup_enabled = false
        @devise_backend.save!
      end

      it 'does not let user sign up' do
        get :new, {}, {SERVER_NAME:"#{Rails.application.config.ldap_server[:host]}:#{Rails.application.config.ldap_server[:port]}"}
        expect(response).to redirect_to(root_path)
      end

      after do
        @devise_backend.signup_enabled = true
        @devise_backend.save!
      end
    end
  end
end
