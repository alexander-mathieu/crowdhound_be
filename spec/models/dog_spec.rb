require 'rails_helper'

RSpec.describe Dog, type: :model do
  describe 'relationships' do
    it { should belong_to :user }
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
end
