class User < ActiveRecord::Base
  THOUGHTWORKS_EMAIL = "thoughtworks@techradar.io"

  MissingAdminAccount = Class.new(RuntimeError)

  include Wisper::Publisher

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :radars, foreign_key: 'owner_id'

  def find_radar(id)
    radars.find(id)
  end

  def new_radar(params)
    radars.new(params)
  end

  def add_radar(params)
    new_radar(params).tap(&(:save!))
  end

  after_create do |user|
    publish(:user_created, user)
  end

  def self.admin
    admin = find_by(admin: true)
    admin || fail(MissingAdminAccount)
  end

  def self.thoughtworks
    find_by!(email: THOUGHTWORKS_EMAIL)
  end
end
