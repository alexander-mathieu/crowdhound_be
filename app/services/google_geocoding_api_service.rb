class GoogleGeocodingApiService
  attr_reader :location_string

  def initialize(input_hash = {})
    @location_string = input_hash[:location_string]
  end

  def geocode
    uri_path = '/maps/api/geocode/json'
    Rails.logger.debug "Making Google geocoding API call (#{@location_string})"
    location_hash = fetch_json_data(uri_path, address: @location_string)
    check_and_raise_error(location_hash)
    location_hash
  end

  private

  def conn
    @conn ||= Faraday.new(:url => 'https://maps.googleapis.com') do |faraday|
      faraday.adapter Faraday.default_adapter
      faraday.params['key'] = ENV['GOOGLE_MAPS_API_KEY']
    end
  end

  def fetch_json_data(uri_path, params = {})
    response = conn.get uri_path, params
    JSON.parse response.body, symbolize_names: true
  end

  def check_and_raise_error(response)
    error_message = response[:error_message]
    raise "#{self.class} error: #{error_message}" if error_message
  end
end
