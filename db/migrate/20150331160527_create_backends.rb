class CreateBackends < ActiveRecord::Migration
  def change
    create_table :backends do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
