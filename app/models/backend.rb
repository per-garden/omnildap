class Backend < ActiveRecord::Base
  validates_presence_of :host
  has_and_belongs_to_many :users

  def authenticate(name, password)
    # To be overridden
    false
  end

  def valid_bind?(password)
    false
  end
end
