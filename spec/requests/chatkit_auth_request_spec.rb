require 'rails_helper'

RSpec.describe 'chatkit_auth request endpoint' do
  describe 'with a valid user token' do
    it 'finds a user and returns authentication data' do
      user = create(:user)

      post '/chatkit_auth', params: { token: user.token }

      data = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful

      expect(data).to have_key(:access_token)
      expect(data).to have_key(:token_type)
      expect(data).to have_key(:expires_in)
    end
  end

  describe 'with an invalid user token' do
    it 'returns an invalid token error' do
      post '/chatkit_auth', params: { token: 'invalid token' }

      data = JSON.parse(response.body, symbolize_names: true)

      expect(response.status).to eq(401)

      expect(data[:error]).to eq('Unauthorized')
    end
  end
end
