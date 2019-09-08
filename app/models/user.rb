class User < ApplicationRecord
  has_one :location
  has_many :dogs
  has_many :photos, as: :photoable

  validates_presence_of :first_name, :last_name, :email
  validates :email, uniqueness: { case_sensitive: false }

  def distance_to(user_or_dog)
    return if !user_or_dog.location || !location

    # Formulas based on http://jonisalonen.com/2014/computing-distance-between-coordinates-can-be-simple-and-fast/

    x = location.lat - user_or_dog.location.lat

    lat_in_radians = location.lat * Math::PI / 180
    y = (location.long - user_or_dog.location.long) * Math.cos(lat_in_radians)

    degree_length_in_km = 110.25
    degree_length_in_mi = degree_length_in_km / 1.60934
    degree_length_in_mi * Math.sqrt(x*x + y*y)
  end
end
