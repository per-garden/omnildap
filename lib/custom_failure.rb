class CustomFailure < Devise::FailureApp
  # Failing devise login => LDAP
  def redirect_url
    "#{root_url}" + 'auth/ldap'
  end

  # Avoiding recall
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
