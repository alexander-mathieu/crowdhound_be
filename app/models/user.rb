class User < ApplicationRecord
  has_one :location
  has_many :dogs
  has_many :photos, as: :photoable

  validates_presence_of :first_name, :last_name, :email
  validates :email, uniqueness: { case_sensitive: false }
end
