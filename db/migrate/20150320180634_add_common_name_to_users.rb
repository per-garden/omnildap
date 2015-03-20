class AddCommonNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :common_name, :string
  end
end
