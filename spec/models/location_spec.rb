require 'rails_helper'

RSpec.describe Location, type: :model do
  describe 'relationships' do
    it { should belong_to :user }
  end

  describe 'validations' do
    it { should validate_presence_of :zip_code }
  end

  describe 'hooks' do
    before :each do
      user = create(:user)

      VCR.use_cassette('location_model_spec/before_save_location_hook_create') do
        @location = Location.create!(
          user: user,
          street_address: '1331 17th Street',
          city: 'Denver',
          state: 'CO',
          zip_code: '80202'
        )
      end
    end

    it 'updates lat/long on model create' do
      expect(@location.lat).to be_within(0.001).of(39.751138)
      expect(@location.long).to be_within(0.001).of(-104.996928)
    end

    it 'updates lat/long on model update' do
      VCR.use_cassette('location_model_spec/before_save_location_hook_update') do
        @location.update(
          street_address: '15330 East 120th Place',
          city: 'Commerce City',
          state: 'CO',
          zip_code: '80022'
        )
      end

      expect(@location.lat).to be_within(0.001).of(39.915366)
      expect(@location.long).to be_within(0.001).of(-104.769292)
    end
  end
end
