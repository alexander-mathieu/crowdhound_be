require 'rails_helper'

RSpec.describe 'authenticateUser mutation', type: :request do
  before :each do
    @existing_user = create(:user)
    @api_key = ENV['EXPRESS_API_KEY']
  end

  describe 'with a valid API key and an existing user in the database' do
    it 'finds and returns the user' do
      mutation = authenticate_user_mutation(@existing_user, @api_key)

      post '/graphql', params: { query: mutation }

      json = JSON.parse(response.body, symbolize_names: true)

      data = json[:data][:authenticateUser]

      expect(data[:currentUser]).to include(
        firstName: @existing_user.first_name,
        lastName: @existing_user.last_name,
        email: @existing_user.email
      )

      expect(data[:new]).to eq(false)

      expect(data[:token]).to eq(@existing_user.reload.token)
    end
  end

  describe 'with a valid API key and no user in the database' do
    it 'creates and returns a new user' do
      user = double(
        first_name: 'Bob',
        last_name: 'Smith II',
        email: 'bobsmithii@bs.com',
        token: 'thisisthesecondbesttoken',
      )

      mutation = authenticate_user_mutation(user, @api_key)

      post '/graphql', params: { query: mutation }

      json = JSON.parse(response.body, symbolize_names: true)

      data = json[:data][:authenticateUser]

      expect(data[:currentUser]).to include(
        firstName: user.first_name,
        lastName: user.last_name,
        email: user.email
      )

      expect(data[:new]).to eq(true)

      expect(data[:token]).to eq(User.last.token)
    end
  end

  describe 'without a valid API key' do
    it 'it does not return an authenticated user' do
      invalid_api_key = 'invalidkey'

      mutation = authenticate_user_mutation(@existing_user, invalid_api_key)

      post '/graphql', params: { query: mutation }

      json = JSON.parse(response.body, symbolize_names: true)

      data = json[:data][:authenticateUser]
      error_message = json[:errors][0][:message]

      expect(data).to be_nil
      expect(error_message).to eq('Invalid API key')
    end
  end

  def authenticate_user_mutation(user, api_key)
    "mutation {
      authenticateUser(
        apiKey: \"#{api_key}\",
        auth: {
          firstName: \"#{user.first_name}\"
          lastName: \"#{user.last_name}\"
          email: \"#{user.email}\"
        }
      ) {
        currentUser {
          #{current_user_type_attributes}
        }
        new
        token
      }
    }"
  end
end
