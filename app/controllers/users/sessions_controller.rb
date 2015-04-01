class Users::SessionsController < Devise::SessionsController
  def create
    email = params['user']['email']
    current_user = User.find_by_email(email)
    unless current_user
      # Name for backend is what's in front of the mail domain
      name = email.split('@')[0]
      password = params['user']['password']
      backends_signup(email, name, password)
    end
    super
  end

  private

  def backends_signup(email, name, password)
    # With which backends does user already exist?
    Backend.all.each do |b|
      b.signup(email, name, password)
    end
  end

end
