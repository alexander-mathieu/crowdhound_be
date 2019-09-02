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
  end
end
