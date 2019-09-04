require 'rails_helper'

RSpec.describe Location, type: :model do
  describe 'relationships' do
    it { should belong_to :user }
  end

  describe 'validations' do
    it { should validate_presence_of :zip_code }
  end
end
