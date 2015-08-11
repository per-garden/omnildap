class AddBlockedToBackend < ActiveRecord::Migration
  def change
    add_column :backends, :blocked, :boolean, default: false
  end
end
