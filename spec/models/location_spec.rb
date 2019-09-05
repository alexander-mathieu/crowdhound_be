require 'rails_helper'

RSpec.describe Location, type: :model do
  describe 'relationships' do
    it { should belong_to :user }
  end

  describe 'validations' do
    it { should validate_presence_of :zip_code }
  end

  describe 'instance methods' do
    it '#update_latlong' do
      user = create(:user)

      location = create(:location,
        user: user,
        street_address: '1331 17th Street',
        city: 'Denver',
        state: 'CO',
        zip_code: '80202'
      )

      expect(location.lat).to be_within(0.001).of(39.751138)
      expect(location.long).to be_within(0.001).of(-104.996928)

      location.update(
        street_address: '15330 East 120th Place',
        city: 'Commerce City',
        state: 'CO',
        zip_code: '80022'
      )

      expect(location.lat).to be_within(0.001).of(39.915366)
      expect(location.long).to be_within(0.001).of(-104.808407)
    end
  end
end
