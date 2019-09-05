require 'rails_helper'

RSpec.describe Dog, type: :model do
  describe 'relationships' do
    it { should belong_to :user }
    it { should have_one(:location).through(:user) }
    it { should have_many :photos }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:breed) }
    it { should validate_presence_of(:birthdate) }
    it { should validate_presence_of(:weight) }
    it { should validate_presence_of(:activity_level) }

    it { should validate_numericality_of(:activity_level).only_integer }
    it { should validate_numericality_of(:activity_level).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:activity_level).is_less_than_or_equal_to(2) }
  end

  describe 'instance methods' do
    before :each do
      allow(Time).to receive(:now).and_return('Fri, 15 Apr 2018'.to_time)

      @dog = create(:dog, birthdate: 'Fri, 15 Apr 2011')
    end

    it '#age' do
      expect(@dog.age).to eq(7.000828216869614)
    end
    
    it '#distance_to calculates the distance to a user in miles' do
      user_instance = create(:user)
      location = instance_double("Location", lat: 39.75113810000001, long: -104.996928)
      dog_instance = create(:dog, user: user_instance)
      allow(dog_instance).to receive(:location) { location }
      
      other_user = create(:user)
      other_location = instance_double("Location", lat: 39.7532, long: -105.0002)
      allow(other_user).to receive(:location) { other_location }
  
      expect(dog_instance.distance_to(other_user)).to be_within(0.05).of(0.22)
    end
  
    it '#distance_to calculates the distance to a dog in miles' do
      user_instance = create(:user)
      location = instance_double("Location", lat: 39.75113810000001, long: -104.996928)
      dog_instance = create(:dog, user: user_instance)
      allow(dog_instance).to receive(:location) { location }
  
      other_user = create(:user)
      other_location = instance_double("Location", lat: 39.7532, long: -105.0002)
      other_dog = create(:dog, user: other_user)
      allow(other_dog).to receive(:location) { other_location }
  
      expect(dog_instance.distance_to(other_dog)).to be_within(0.05).of(0.22)
    end
  end
end
