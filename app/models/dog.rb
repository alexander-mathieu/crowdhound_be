class Dog < ApplicationRecord
  belongs_to :user
  has_one :location, through: :user
  has_many :photos, as: :photoable
  
  validates_presence_of :name, :breed, :birthdate, :weight, :activity_level
  validates :activity_level, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 2 }

  def age
    (Time.now - birthdate.to_time) / 1.year.seconds
  end

  def self.sorted_by_distance(user_instance, limit = nil)
    user_lat = user_instance.location.lat
    user_long = user_instance.location.long
    user_cos = Math.cos(user_lat * Math::PI / 180)

    degree_length_in_mi = 110.25 / 1.60934
    x = "(#{user_lat} - locations.lat)"
    y = "((#{user_long} - locations.long) * #{user_cos})"

    select("dogs.*, #{degree_length_in_mi} * |/ (#{x} ^ 2 + #{y} ^ 2) AS distance")
    .joins(user: :location)
    .where.not(users: { id: user_instance.id })
    .order('distance', :id)
    .limit(limit)
  end
end
