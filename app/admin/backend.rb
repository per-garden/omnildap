ActiveAdmin.register Backend do

  config.clear_action_items!

  action_item :only => :index do
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
    end

    private

    def authenticate_user!
      redirect_to(root_path) unless current_user && current_user.admin
    end
  end

end
