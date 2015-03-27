class AuthenticationsController < ApplicationController
  # FIXME: How to verify that auth reply stems from right source?
  skip_before_filter :verify_authenticity_token, only: :create

  def create
    auth = request.env['omniauth.auth']
    email = auth['info']['email']
    # Is this specific to Apache DS, or generally usable.
    password = auth['extra']['raw_info']['userpassword'][0]
    # Expecting uid as 'cn=..', and using that as name
    name = auth['info']['uid'].split(',')[0].split('=')[1]
    current_user = User.find_by_email(email)
    unless current_user
      current_user = User.create!(email: email, name: name, password: password, password_confirmation: password)
      sign_in current_user
    end
    redirect_to user_session_path
  end
end
