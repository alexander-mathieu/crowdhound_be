module Distanceable
  def distance_to(user_or_dog)
    # Formulas based on http://jonisalonen.com/2014/computing-distance-between-coordinates-can-be-simple-and-fast/

    x = self.location.lat - user_or_dog.location.lat

    lat_in_radians = self.location.lat * Math::PI / 180
    y = (self.location.long - user_or_dog.location.long) * Math.cos(lat_in_radians)

    degree_length_in_km = 110.25
    degree_length_in_mi = degree_length_in_km / 1.60934
    degree_length_in_mi * Math.sqrt(x*x + y*y)
  end
end
