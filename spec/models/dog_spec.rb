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
  end

  describe 'class methods' do
    it '.sorted_by_distance' do
      VCR.use_cassette('dog_model_spec/sorted_by_distance') do
        user_instance = create(:user)
        Location.create!(
          user: user_instance,
          street_address: '1331 17th Street',
          city: 'Denver',
          state: 'CO',
          zip_code: '80202'
        )

        u1 = create(:user) # 0.89 miles away
        d1 = create(:dog, user: u1)
        Location.create!(
          user: u1,
          street_address: '494 East 19th Avenue',
          city: 'Denver',
          state: 'CO',
          zip_code: '80203'
        )

        u2 = create(:user) # 16.46 miles away
        d2 = create(:dog, user: u2)
        Location.create!(
          user: u2,
          street_address: '15330 East 120th Place',
          city: 'Commerce City',
          state: 'CO',
          zip_code: '80022'
        )

        u3 = create(:user) # 2.85 miles away
        d3 = create(:dog, user: u3)
        Location.create!(
          user: u3,
          street_address: '2001 Colorado Boulevard',
          city: 'Denver',
          state: 'CO',
          zip_code: '80205'
        )

        sorted = Dog.sorted_by_distance(user_instance)

        expect(sorted[0]).to eq(d1)
        expect(sorted[0].distance).to be_within(0.05).of(0.89)

        expect(sorted[1]).to eq(d3)
        expect(sorted[1].distance).to be_within(0.05).of(2.85)

        expect(sorted[2]).to eq(d2)
        expect(sorted[2].distance).to be_within(0.05).of(16.46)
      end
    end
  end
end
