class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates_presence_of :name, :email
  has_and_belongs_to_many :backends
  validates_presence_of :backends, :message => 'must not be empty'
  validate :backend_user_uniqueness
  after_initialize :init

  def valid_bind?(password)
    result = false
    backends.each do |b|
      result ||= b.authenticate(name, password)
    end
    result
  end

  private

  def init
    self.admin ||= false
    self.blocked ||= false
  end

  def backend_user_uniqueness
    exists = (DeviseBackend.instance.users.map {|u| u.name}).include?(name)
    (Backend.all.reject {|b| b.type == 'DeviseBackend'}).each do |b|
      exists &= (b.users.map {|u| u.name}).include?(name)
    end
    if exists
      errors.add(:name, "#{name} already on all connected backends")
    end
   exists = (DeviseBackend.instance.users.map {|u| u.email}).include?(email)
   (Backend.all.reject {|b| b.type == 'DeviseBackend'}).each do |b|
     exists &= (b.users.map {|u| u.email}).include?(email)
   end
   if exists
     errors.add(:email, "#{email} already on all connected backends")
   end
  end

end
