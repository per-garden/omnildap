# Not used - remove this file (see config/initializers/devise.rb)
class CustomFailure < Devise::FailureApp
  # Failing devise login => LDAP
  def redirect_url
    "#{root_url}" + 'auth/ldap'
    # "#{root_url}" + 'auth/ldap/callback', {email: email, password: password}, method: :post
  end

  # Avoiding recall
  def respond
    if http_auth?
      http_auth
    else
      # redirect
      email = params[:user][:email]
      password= params[:user][:password]
      redirect_to "#{root_url}" + 'auth/ldap/callback', email: email, password: password, method: 'POST'
    end
  end
end
