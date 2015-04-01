class AddTypeToBackend < ActiveRecord::Migration
  def change
    add_column :backends, :type, :string
  end
end
