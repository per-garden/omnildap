ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :backends_id, label: 'Backend', collection: proc { Backend.all.map {|b| [b.name_string, b.id] } }, as: :select
  filter :groups_id, label: 'Group', collection: proc { Group.all.map {|g| [g.name, g.id] } }, as: :select
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

    def create
      user = User.new(user_create_params)
      user.backends << DeviseBackend.instance
      if params[:user][:groups]
        params[:user][:groups].each do |gid|
          g = Group.find(gid.to_i)
          user.groups << g if g
        end
      end
      if user && user.save
        redirect_to admin_user_path(user), notice: 'User was created.'
      else
        redirect_to admin_users_path, alert: 'Unable to create user'
      end      
    end

    def show
      @user = User.find(params[:id])
    end

    def update
      user = User.find(params[:id])
      user.update(user_update_params)
      groups = []
      if params[:user][:groups]
        params[:user][:groups].each do |gid|
          g = Group.find(gid.to_i)
          groups << g
        end
      end
      user.groups = groups

      if user && user.save
        redirect_to admin_user_path(user), notice: 'User was updated.'
      else
        redirect_to admin_users_path, alert: 'Unable to update user'
      end
    end

    def destroy
      user = User.find(params[:id])
      notice = ''
      if user && user.destroy
        notice = 'User deleted'
      else
        notice = "Unable to delete user #{user.name}"
      end
      redirect_to admin_users_path, notice: notice
    end

    private

    def authenticate_user!
      redirect_to(root_path) unless current_user && current_user.admin
    end

    def user_create_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :admin, :blocked, :groups)
    end

    def user_update_params
      params.require(:user).permit(:name, :email, :admin, :blocked, :groups)
    end

  end

end
