class Backend < ActiveRecord::Base
  validates_presence_of :host
  has_and_belongs_to_many :users
end
