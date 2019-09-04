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
end
