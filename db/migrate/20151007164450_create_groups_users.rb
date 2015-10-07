class CreateGroupsUsers < ActiveRecord::Migration
  def change
    create_table :groups_users, :id => false do |t|
      t.references :group, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
