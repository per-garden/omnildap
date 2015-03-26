class AuthenticationsController < ApplicationController
  # FIXME: How to verify that auth reply stems from right source?
  skip_before_filter :verify_authenticity_token, only: :create

  def create
    auth = request.env['omniauth.auth']
    email = auth['info']['email']
    # Expecting uid as 'cn=..'
    cn = auth['info']['uid'].split(',')[0].split('=')[1]
    current_user = User.find_by_email(email)
    unless current_user
      current_user = User.new(email: email, common_name: cn)
      current_user.save
      sign_in current_user
      flash[:notice] = 'Authentication successful'
    end
    redirect_to user_session_path
  end
end
