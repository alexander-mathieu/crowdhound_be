class Dog < ApplicationRecord
  belongs_to :user

  validates_presence_of :name, :breed, :birthdate, :weight, :activity_level
  validates :activity_level, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 2 }

  def age
    ((Time.zone.now - birthdate.to_time) / 1.year.seconds)
  end
end
