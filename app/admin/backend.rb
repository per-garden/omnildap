ActiveAdmin.register Backend do

  config.clear_action_items!

  action_item 'new_dropdown', only: :index do
    render partial: 'new_dropdown'
  end

  index do
    column :type
    column :name_string
    column :description
    column :blocked
    actions
  end

  filter :type
  filter :name
  filter :description
  filter :host
  filter :port
  filter :base
  filter :blocked
  filter :email_pattern
  filter :filter
  filter :domain
  filter :users

  form do |f|
    # ActiveAdmin madness! Already fetched in controller!
    if params[:type] == 'DeviseBackend'
      # Singleton!
      @backend = DeviseBackend.instance
    else
      @backend = Backend.new(type: params[:type])
    end
    render partial: 'form'
  end

  controller do

    def new
      if params[:type] == 'DeviseBackend'
        # Singleton!
        @backend = DeviseBackend.instance
      else
        @backend = Backend.new(type: params[:type])
      end
      @page_title = "New #{@backend.type}"
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
        redirect_to admin_backend_path(backend), notice: 'Authentication backend was created.'
      else
        redirect_to admin_backends_path
      end
    end
  
    private
  
    def authenticate_user!
      redirect_to(root_path) unless current_user && current_user.admin
    end

    def devise_backend_params
      params.require(:devise_backend).permit(:name, :description, :blocked, :email_pattern, :signup_enabled)
    end
  
    def ldap_backend_params
      params.require(:ldap_backend).permit(:name, :description, :host, :base, :port, :admin_name, :admin_password, :blocked, :email_pattern)
    end
  
    def active_directory_backend_params
      params.require(:active_directory_backend).permit(:name, :description, :host, :base, :port, :admin_name, :admin_password, :blocked, :email_pattern, :domain)
    end

  end

end
