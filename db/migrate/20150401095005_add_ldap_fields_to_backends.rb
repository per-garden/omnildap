class AddLdapFieldsToBackends < ActiveRecord::Migration
  def change
    add_column :backends, :host, :string
    add_column :backends, :port, :int
    add_column :backends, :base, :string
  end
end
