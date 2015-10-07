class AddUserNameIndex < ActiveRecord::Migration
  def up
    add_index :users, :name, unique: true
  end

  def down
    remove_index(:users, :name => 'index_users_on_name')
  end
end
