ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :name
  filter :email
  filter :admin
  filter :email
  filter :blocked

  show do
    render partial: 'show'
  end

  form do |f|
    render partial: 'form'
  end

  controller do

    def new
      @user = User.new
      @user.backends << DeviseBackend.instance
    end

    def show
      @user = User.find(params[:id])
    end

    private

    def authenticate_user!
      redirect_to(root_path) unless current_user && current_user.admin
    end

  end

end
