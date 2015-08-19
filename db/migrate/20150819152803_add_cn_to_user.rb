class AddCnToUser < ActiveRecord::Migration
  def change
    add_column :users, :cn, :string
  end
end
