class Backend < ActiveRecord::Base
  validates_presence_of :host
  has_and_belongs_to_many :users
  after_initialize :init

  def authenticate(name, password)
    # To be overridden
    false
  end

  def valid_bind?(password)
    false
  end

  # Abstactly mimicking ldap by giving empty hash
  def find_users
    {}
  end

  private

  def init
    backends ||= []
  end
end
