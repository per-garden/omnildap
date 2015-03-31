class BackendsUsers < ActiveRecord::Base
  belongs_to :backend
  belongs_to :user
end
