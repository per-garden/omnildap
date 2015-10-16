ActiveAdmin.register Group do

  index do
    selectable_column
    id_column
    column :name
    column :created_at
    actions
  end

  filter :users_id, label: 'User', collection: proc { User.all.map {|u| ["#{u.name} - #{u.email}", u.id] } }, as: :select
  filter :name

  show do
    render partial: 'show'
  end

  form do |f|
    render partial: 'form'
  end

  controller do

    def new
      @group = Group.new
    end

    def create
      group = Group.new(group_create_params)
      params[:group][:users].each do |uid|
        u = User.find(uid.to_i)
        group.users << u if u
      end
      if group && group.save
        redirect_to admin_group_path(group), notice: 'Group was created.'
      else
        redirect_to admin_groups_path, alert: 'Unable to create group'
      end      
    end

    def show
      @group = Group.find(params[:id])
    end

    def update
      group = Group.find(params[:id])
      group.update(group_update_params)
      users = []
      params[:group][:users].each do |uid|
        u = User.find(uid.to_i)
        users << u
      end
      group.users = users

      if group && group.save
        redirect_to admin_group_path(group), notice: 'Group was updated.'
      else
        redirect_to admin_groups_path, alert: 'Unable to update group'
      end
    end

    def destroy
      group = Group.find(params[:id])
      notice = ''
      if group && group.destroy
        notice = 'Group deleted'
      else
        notice = "Unable to delete group #{group.name}"
      end
      redirect_to admin_groups_path, notice: notice
    end

    private

    def authenticate_user!
      redirect_to(root_path) unless current_user && current_user.admin
    end

    def group_create_params
      params.require(:group).permit(:name, :users)
    end

    def group_update_params
      params.require(:group).permit(:name, :users)
    end

  end

end
