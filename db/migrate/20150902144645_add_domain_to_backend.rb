class AddDomainToBackend < ActiveRecord::Migration
  def change
    add_column :backends, :domain, :string
  end
end
