class User < ApplicationRecord
  has_many :dogs

  validates_presence_of :first_name, :last_name, :email
  validates :email, uniqueness: { case_sensitive: false }
end
