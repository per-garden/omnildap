class BackendsController < ApplicationController
  before_filter :require_admin

  def new
    if params[:type] == 'DeviseBackend'
      # Singleton!
      @backend = DeviseBackend.instance
    else
      @backend = Backend.new(type: params[:type])
    end
  end

  def create
    type = params.keys[2]
    case type
    when 'devise_backend'
      # Singleton!
      backend = DeviseBackend.instance
      backend.update(devise_backend_params)
    when 'ldap_backend'
      backend = LdapBackend.new(ldap_backend_params)
    when 'active_directory_backend'
      backend = ActiveDirectoryBackend.new(active_directory_backend_params)
    end

    if backend && backend.save!
      redirect_to backend_path(backend), notice: 'Authentication backend was created.'
    else
      redirect_to backends_path
    end
  end

  def index
    @backends = Backend.all
  end

  def show
    @backend = Backend.find(params[:id])
  end

  def edit
    @backend = Backend.find(params[:id])
  end

  def update
    type = params.keys[3]
    case type
    when 'devise_backend'
      backend = Backend.find(params[:id])
      backend.update(devise_backend_params)
    when 'ldap_backend'
      backend = Backend.find(params[:id])
      backend.update(ldap_backend_params)
    when 'active_directory_backend'
      backend = Backend.find(params[:id])
      backend.update(active_directory_backend_params)
    end

    if backend && backend.save
      redirect_to backend_path(backend), notice: 'Authentication backend was updated.'
    else
      redirect_to backends_path
    end
  end

  private

  def devise_backend_params
    params.require(:devise_backend).permit(:name, :description, :blocked, :email_pattern, :signup_enabled)
  end

  def ldap_backend_params
    params.require(:ldap_backend).permit(:name, :description, :host, :base, :port, :admin_name, :admin_password, :blocked, :email_pattern)
  end

  def active_directory_backend_params
    params.require(:active_directory_backend).permit(:name, :description, :host, :base, :port, :admin_name, :admin_password, :blocked, :email_pattern)
  end
end
