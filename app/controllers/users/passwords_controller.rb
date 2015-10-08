class Users::PasswordsController < Devise::PasswordsController

  def create
    email = params[:user][:email]
    u = User.find_by_email(email)
    if DeviseBackend.instance.signup_enabled || (u && DeviseBackend.instance.users.include?(u))
      super
    else
      redirect_to new_user_session_path
    end
  end
end
