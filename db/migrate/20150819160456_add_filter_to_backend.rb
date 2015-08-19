class AddFilterToBackend < ActiveRecord::Migration
  def change
    add_column :backends, :filter, :string
  end
end
