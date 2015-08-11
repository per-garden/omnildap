class Backend < ActiveRecord::Base
  has_and_belongs_to_many :users
  after_initialize :init

  def authenticate(name, password)
    # To be overridden
    false
  end

  def valid_bind?(password)
    false
  end

  def find_users
    []
  end

  # Default name to id when no name set
  def name_string
    name.blank? ? id.to_s : name
  end

  private

  def init
    self.blocked ||= false
    self.email_pattern ||= '.*@.*'
  end
end
