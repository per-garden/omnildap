class Users::SessionsController < Devise::SessionsController
  def create
    # TODO: Attempt backends the user is connected to. Default is devise = "super"
    # omniauth = {}
    # redirect_to omniauth_path(:create, provider: 'ldap', omniauth: omniauth)
    super
  end
end
