class AddSignupEnabledToBackend < ActiveRecord::Migration
  def change
    add_column :backends, :signup_enabled, :boolean, default: true
  end
end
