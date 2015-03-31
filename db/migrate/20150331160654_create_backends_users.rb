class CreateBackendsUsers < ActiveRecord::Migration
  def change
    create_table :backends_users, :id => false do |t|
      t.references :backend, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
