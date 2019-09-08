require 'rails_helper'

RSpec.describe 'add location mutation', type: :request do
  before :each do
    @existing_user = create(:user)
  end

  describe 'with a valid Google token and valid location' do
    it 'creates a new location' do
      VCR.use_cassette('add_location_mutation_spec/valid_location') do
        mutation = add_valid_location_mutation

        post '/graphql', params: {
                           google_token: @existing_user.google_token,
                           query: mutation
                         }

        json = JSON.parse(response.body, symbolize_names: true)

        data = json[:data][:addLocation]

        expect(data[:message]).to eq('Location successfully added')
      end
    end
  end

  describe 'with a valid Google token and invalid location' do
    it 'does not create a new location' do
      VCR.use_cassette('add_location_mutation_spec/invalid_location') do
        mutation = add_invalid_location_mutation

        post '/graphql', params: {
                           google_token: @existing_user.google_token,
                           query: mutation
                         }
        json = JSON.parse(response.body, symbolize_names: true)

        data = json[:data][:addLocation]
        error_message = json[:errors][0][:message]

        expect(data).to be_nil
        expect(error_message).to eq('Invalid address entered')
      end
    end
  end

  describe 'with an invalid Google token' do
    it 'does not create a new location' do
      user = double(
        first_name: 'Bob',
        last_name: 'Smith II',
        email: 'bobsmithii@bs.com',
        google_token: 'thisisthesecondbesttoken',
      )

      mutation = add_valid_location_mutation

      post '/graphql', params: {
                         google_token: user.google_token,
                         query: mutation
                       }

      json = JSON.parse(response.body, symbolize_names: true)

      data = json[:data][:addLocation]
      error_message = json[:errors][0][:message]

      expect(data).to be_nil
      expect(error_message).to eq('Unauthorized - a valid google_token query parameter is required')
    end
  end

  def add_valid_location_mutation
    "mutation {
      addLocation(
        location: {
          streetAddress: \"1331 17th Street\",
          city: \"Denver\",
          state: \"CO\",
          zipCode: \"80202\"
        }
      ) {
        message
      }
    }"
  end

  def add_invalid_location_mutation
    "mutation {
      addLocation(
        location: {
          streetAddress: \"12345 Seeded Rye Bread Lane\",
          city: \"Breadtown\",
          state: \"OP\",
          zipCode: \"12345\"
        }
      ) {
        message
      }
    }"
  end
end
