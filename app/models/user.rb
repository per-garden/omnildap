class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates_presence_of :name, :email
  has_and_belongs_to_many :backends
  has_and_belongs_to_many :groups
  validates_presence_of :backends, :message => 'must not be empty'
  after_initialize :init

  def valid_bind?(password)
    result = false
    backends.each do |b|
      result ||= b.authenticate(name, password)
    end
    if !result && DeviseBackend.instance.signup_enabled
      result = DeviseBackend.instance.authenticate(name, password)
      backends << DeviseBackend.instance if result
    end
    result
  end

  private

  def init
    self.admin ||= false
    self.blocked ||= false
  end

end
