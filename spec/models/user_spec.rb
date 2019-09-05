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
      current_user = create(:user)
      create(:location, user: current_user, lat: 39.75113810000001, long: -104.996928)

      other_user = create(:user)
      create(:location, user: other_user, lat: 39.7532, long: -105.0002)

      expect(current_user.distance_to(other_user)).to be_within(0.05).of(0.22) # 0.22 miles = 0.36 km
    end

    it '#distance_to calculates the distance to a dog in miles' do
      current_user = create(:user)
      create(:location, user: current_user, lat: 39.75113810000001, long: -104.996928)

      other_user = create(:user)
      create(:location, user: other_user, lat: 39.7532, long: -105.0002)
      dog = create(:dog, user: other_user)

      expect(current_user.distance_to(dog)).to be_within(0.05).of(0.22) # 0.22 miles = 0.36 km
    end
  end
end
