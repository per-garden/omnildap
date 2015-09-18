ActiveAdmin.register Backend do

  config.clear_action_items!

  action_item :only => :index do
    label 'New: '
  end
  ['DeviseBackend', 'LdapBackend', 'ActiveDirectoryBackend'].each do |b|
    # How does one make Arbre piece of crap create neat drop down?
    action_item :only => :index do
      link_to b, new_backend_path(type: b)
    end
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

  controller do

    private

    def authenticate_user!
      redirect_to(root_path) unless current_user && current_user.admin
    end
  end
end
