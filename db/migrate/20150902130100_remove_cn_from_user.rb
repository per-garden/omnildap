class RemoveCnFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :cn
  end
end
