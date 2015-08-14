class Users::SessionsController < Devise::SessionsController

  def create
    login = params['user']['name']
    # Allow login with either name or email
    user = User.find_by_name(login) || User.find_by_email(login)
    if user && user.valid_bind?(params['user']['password'])
      sign_in user
    end
    super
  end
end
