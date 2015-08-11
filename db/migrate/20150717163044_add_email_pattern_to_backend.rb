class AddEmailPatternToBackend < ActiveRecord::Migration
  def change
    add_column :backends, :email_pattern, :string, default: '.*@.*'
  end
end
