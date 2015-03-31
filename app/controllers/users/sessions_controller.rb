class Users::SessionsController < Devise::SessionsController
  def create
    email = params['user']['email']
    current_user = User.find_by_email(email)
    unless current_user
      password = params['user']['password']
      backend_signup(email, password)
    end
    super
  end

  private

  def backend_signup(email, password)
    # Name for backend is what's in front of the mail domain
    name = email.split('@')[0]
    ldap = Net::LDAP.new
    ldap.port = 10389
    ldap.base = 'ou=seldlx3031_apache_ds,dc=example,dc=com'
    ldap.authenticate("cn=#{name},ou=seldlx3031_apache_ds,dc=example,dc=com", password)
    if ldap.bind
      User.create!(email: email, name: name, password: password, password_confirmation: password)
    end
  end
end
