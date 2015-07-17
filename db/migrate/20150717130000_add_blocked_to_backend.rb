class AddBlockedToBackend < ActiveRecord::Migration
  def change
    add_column :backends, :blocked, :boolean
  end
end
