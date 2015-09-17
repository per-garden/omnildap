ActiveAdmin.register Backend do
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

  controller do
    before_filter :authorise

    private

    def authorise
      redirect_to(root_path) unless current_user && current_user.admin
    end
  end
end
