class UserCommonNameToName < ActiveRecord::Migration
  def change
    rename_column :users, :common_name, :name
  end
end
