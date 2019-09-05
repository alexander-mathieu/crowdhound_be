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
end
