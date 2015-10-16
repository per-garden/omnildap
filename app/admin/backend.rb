ActiveAdmin.register Backend do

  config.clear_action_items!

  action_item 'new_dropdown', only: :index do
    render partial: 'new_dropdown'
  end

  action_item 'edit', only: :show do
    link_to 'Edit Backend', edit_admin_backend_path
  end

  action_item 'delete', only: :show do
    link_to 'Delete Backend', admin_backend_path, method: :delete
  end

  index do
    column :type
    column :name_string
    column :description
    column :blocked
    actions
  end

  filter :users_id, label: 'User', collection: proc { User.all.map {|u| ["#{u.name} - #{u.email}", u.id] } }, as: :select
  filter :type, as: :select, collection: -> { ["DeviseBackend", "LdapBackend", "ActiveDirectoryBackend"] }
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

  show do
    render partial: 'show'
  end

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
        @page_title = "Update #{@backend.type}"
      else
        @backend = Backend.new(type: params[:type])
        @page_title = "New #{@backend.type}"
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
  
      if backend && backend.save
        redirect_to admin_backend_path(backend), notice: 'Backend was created.'
      else
        redirect_to admin_backends_path, alert:  'Unable to create backend'
      end
    end

    def show
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
        redirect_to admin_backend_path(backend), notice: 'Backend was updated.'
      else
        redirect_to admin_backends_path, alert:  'Unable to update backend'
      end
    end

    def destroy
      backend = Backend.find(params[:id])
      notice = ''
      if backend && backend.destroy
        notice = 'Backend deleted'
      else
        notice = "Unable to delete backend #{backend.name_string}"
      end
      redirect_to admin_backends_path, notice: notice
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
