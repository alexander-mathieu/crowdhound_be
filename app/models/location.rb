class Location < ApplicationRecord
  belongs_to :user

  validates_presence_of :zip_code

  before_save :update_latlong

  private

  def update_latlong
    location = request_new_latlong
    self.lat = location[:lat]
    self.long = location[:lng]
  end

  def request_new_latlong
    response = google_geocoding_api_service.geocode
    response[:results].first[:geometry][:location]
  end

  def google_geocoding_api_service
    GoogleGeocodingApiService.new(location_string: location_string)
  end

  def location_string
    location_string = ''
    location_string += "#{street_address}, " if street_address
    location_string += "#{city}, "           if city
    location_string += "#{state} "           if state
    location_string += zip_code              if zip_code
  end
end
