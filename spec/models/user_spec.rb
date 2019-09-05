require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'relationships' do
    it { should have_one :location }
    it { should have_many :dogs }
    it { should have_many :photos }
  end

  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'instance methods' do
    it '#distance_to calculates the distance to a user in miles' do
      user_instance = create(:user)
      location = instance_double("Location", lat: 39.75113810000001, long: -104.996928)
      allow(user_instance).to receive(:location) { location }

      other_user = create(:user)
      other_location = instance_double("Location", lat: 39.7532, long: -105.0002)
      allow(other_user).to receive(:location) { other_location }

      expect(user_instance.distance_to(other_user)).to be_within(0.05).of(0.22)
    end

    it '#distance_to calculates the distance to a dog in miles' do
      user_instance = create(:user)
      location = instance_double("Location", lat: 39.75113810000001, long: -104.996928)
      allow(user_instance).to receive(:location) { location }

      other_user = create(:user)
      other_location = instance_double("Location", lat: 39.7532, long: -105.0002)
      dog_instance = create(:dog, user: other_user)
      allow(dog_instance).to receive(:location) { other_location }

      expect(user_instance.distance_to(dog_instance)).to be_within(0.05).of(0.22)
    end
  end

  describe 'class methods' do
    it '.sorted_by_distance' do
      VCR.use_cassette('user_model_spec/sorted_by_distance') do
        user_instance = create(:user)

        Location.create!(
          user: user_instance,
          street_address: '1331 17th Street',
          city: 'Denver',
          state: 'CO',
          zip_code: '80202'
        )

        u1 = create(:user) # 0.89 miles away

        Location.create!(
          user: u1,
          street_address: '494 East 19th Avenue',
          city: 'Denver',
          state: 'CO',
          zip_code: '80203'
        )

        u2 = create(:user) # 16.46 miles away

        Location.create!(
          user: u2,
          street_address: '15330 East 120th Place',
          city: 'Commerce City',
          state: 'CO',
          zip_code: '80022'
        )

        u3 = create(:user) # 2.85 miles away

        Location.create!(
          user: u3,
          street_address: '2001 Colorado Boulevard',
          city: 'Denver',
          state: 'CO',
          zip_code: '80205'
        )

        sorted = User.sorted_by_distance(user_instance)

        expect(sorted[0]).to eq(u1)
        expect(sorted[0].distance).to be_within(0.05).of(0.89)

        expect(sorted[1]).to eq(u3)
        expect(sorted[1].distance).to be_within(0.05).of(2.85)

        expect(sorted[2]).to eq(u2)
        expect(sorted[2].distance).to be_within(0.05).of(16.46)
      end
    end
  end
end
