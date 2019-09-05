class User < ApplicationRecord
  has_one :location
  has_many :dogs
  has_many :photos, as: :photoable

  validates_presence_of :first_name, :last_name, :email
  validates :email, uniqueness: { case_sensitive: false }

  def distance_to(user_or_dog)
    # Formulas based on http://jonisalonen.com/2014/computing-distance-between-coordinates-can-be-simple-and-fast/

    x = self.location.lat - user_or_dog.location.lat

    lat_in_radians = self.location.lat * Math::PI / 180
    y = (self.location.long - user_or_dog.location.long) * Math.cos(lat_in_radians)

    degree_length_in_km = 110.25
    degree_length_in_mi = degree_length_in_km / 1.60934
    degree_length_in_mi * Math.sqrt(x*x + y*y)
  end

  def self.sorted_by_distance(user_instance, limit = nil)
    user_lat = user_instance.location.lat
    user_long = user_instance.location.long
    user_cos = Math.cos(user_lat * Math::PI / 180)
    degree_length_in_mi = 110.25 / 1.60934
    x = "(#{user_lat} - locations.lat)"
    y = "((#{user_long} - locations.long) * #{user_cos})"

    select("users.*, #{degree_length_in_mi} * |/ (#{x} ^ 2 + #{y} ^ 2) AS distance")
    .joins(:location)
    .where.not(id: user_instance.id)
    .order('distance')
    .limit(limit)
  end
end
