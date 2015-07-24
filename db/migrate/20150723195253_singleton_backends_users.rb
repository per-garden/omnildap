class SingletonBackendsUsers < ActiveRecord::Migration
  def change
    remove_index(:backends_users, name: 'index_backends_users')
    add_index(:backends_users,[:backend_id, :user_id], name: 'index_backends_users', :unique => false)
  end
end
