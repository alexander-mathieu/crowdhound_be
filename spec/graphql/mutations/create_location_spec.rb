require 'rails_helper'

RSpec.describe 'createLocation mutation', type: :request do
  before :each do
    @existing_user = create(:user)
  end

  describe 'with a valid token and valid location' do
    it 'creates a new location' do
      VCR.use_cassette('create_location_mutation_spec/valid_location') do
        mutation = create_valid_location_mutation

        post '/graphql', params: {
                           token: @existing_user.token,
                           query: mutation
                         }

        json = JSON.parse(response.body, symbolize_names: true)

        gql_location = json[:data][:createLocation][:location]
        db_location = Location.last

        compare_gql_and_db_locations(gql_location, db_location)
        expect(@existing_user.location.street_address).to eq('1331 17th Street')
      end
    end
  end

  describe 'with a valid token and invalid location' do
    it 'does not create a new location' do
      VCR.use_cassette('create_location_mutation_spec/invalid_location') do
        mutation = create_invalid_location_mutation

        post '/graphql', params: {
                           token: @existing_user.token,
                           query: mutation
                         }
        json = JSON.parse(response.body, symbolize_names: true)

        data = json[:data][:createLocation]
        error_message = json[:errors][0][:message]

        expect(data).to be_nil
        expect(error_message).to eq('Invalid address entered')
        expect(@existing_user.location).to be_nil
      end
    end
  end

  describe 'with an invalid token' do
    it 'does not create a new location' do
      mutation = create_valid_location_mutation

      post '/graphql', params: {
                         token: 'thisisthesecondbesttoken',
                         query: mutation
                       }

      json = JSON.parse(response.body, symbolize_names: true)

      data = json[:data][:createLocation]
      error_message = json[:errors][0][:message]

      expect(data).to be_nil
      expect(error_message).to eq('Unauthorized - a valid token query parameter is required')
      expect(Location.count).to eq(0)
    end
  end

  def create_valid_location_mutation
    "mutation {
      createLocation(
        location: {
          streetAddress: \"1331 17th Street\",
          city: \"Denver\",
          state: \"CO\",
          zipCode: \"80202\"
        }
      ) {
        location {
          #{location_type_attributes}
        }
      }
    }"
  end

  def create_invalid_location_mutation
    "mutation {
      createLocation(
        location: {
          streetAddress: \"12345 Seeded Rye Bread Lane\",
          city: \"Breadtown\",
          state: \"OP\",
          zipCode: \"12345\"
        }
      ) {
        location {
          #{location_type_attributes}
        }
      }
    }"
  end
end
