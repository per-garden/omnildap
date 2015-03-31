class BundleIndicesOnBackendsUsers < ActiveRecord::Migration
  def up
    remove_index(:backends_users, :name => 'index_backends_users_on_backend_id')
    remove_index(:backends_users, :name => 'index_backends_users_on_user_id')
    add_index(:backends_users,[:backend_id, :user_id], name: 'index_backends_users', :unique => true)
  end

  def down
    remove_index(:backends_users, name: 'index_backends_users')
    add_index(:backends_users, ["backend_id"], name: "index_backends_users_on_backend_id")
    add_index(:backends_users, ["user_id"], name: "index_backends_users_on_user_id")
  end
end
