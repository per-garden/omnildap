class Users::RegistrationsController < Devise::RegistrationsController
  def new
    redirect_to root_path unless DeviseBackend.instance.signup_enabled
    super
  end
end
