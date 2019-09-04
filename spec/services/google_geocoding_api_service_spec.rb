require 'rails_helper'

RSpec.describe GoogleGeocodingApiService do
  it 'initializes with a location_string' do
    location_string = '1331 17th St, Denver, CO 80202'
    service = GoogleGeocodingApiService.new(location_string: location_string)

    expect(service.location_string).to eq(location_string)
  end

  it '#geocode returns API response, which includes lat and long' do
    VCR.use_cassette('google_geocoding_api/geocode_good_response', record: :new_episodes) do
      location_string = '1331 17th St, Denver, CO 80202'
      service = GoogleGeocodingApiService.new(location_string: location_string)

      api_response = service.geocode
      location = api_response[:results].first[:geometry][:location]
      expect(location[:lat]).to be_within(0.001).of(39.75113810000001)
      expect(location[:lng]).to be_within(0.001).of(-104.996928)
    end
  end
end
