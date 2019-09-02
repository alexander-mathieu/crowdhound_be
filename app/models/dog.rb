class Dog < ApplicationRecord
  belongs_to :user

  validates_presence_of :name, :breed, :birthdate, :weight, :activity_level
end
