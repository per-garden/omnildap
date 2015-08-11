class Users::RegistrationsController < Devise::RegistrationsController
  def new
    if DeviseBackend.instance.signup_enabled
      super
    else
      redirect_to root_path
    end
  end
end
