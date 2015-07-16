class AddAdminToBackend < ActiveRecord::Migration
  def change
    add_column :backends, :admin_name, :string
    add_column :backends, :admin_password, :string
  end
end
