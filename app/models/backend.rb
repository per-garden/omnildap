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

  def email_blocked?(name)
    u = User.find_by_name(name)
    u && !(u.email.match(/#{self.email_pattern}/))
  end

  def find_users
    []
  end

  # Default name to id when no name set
  def name_string
    name.blank? ? id.to_s : name
  end

  private

  def backend_auth_name(name)
    name
  end

  def init
    self.blocked ||= false
    self.email_pattern ||= '.*@.*'
  end
end
