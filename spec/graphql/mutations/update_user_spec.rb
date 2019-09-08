require 'rails_helper'

RSpec.describe 'updateUser mutation', type: :request do
  before :each do
    @existing_user = create(:user)

    VCR.use_cassette('update_user_mutation_spec/before_each') do
      @existing_location = Location.create!(
        user: @existing_user,
        street_address: '1331 17th Street',
        city: 'Denver',
        state: 'CO',
        zip_code: '80202'
      )
    end
  end

  describe 'with a valid Google token' do
    it 'updates the user' do
      mutation = update_user_mutation

      post '/graphql', params: {
                         google_token: @existing_user.google_token,
                         query: mutation
                       }

      json = JSON.parse(response.body, symbolize_names: true)
      updated_user = json[:data][:updateUser][:currentUser]

      compare_gql_and_db_users(updated_user, @existing_user.reload)
    end

    it 'updates the location' do
      VCR.use_cassette('update_user_mutation_spec/update_location') do
        mutation = update_location_mutation

        post '/graphql', params: {
                           google_token: @existing_user.google_token,
                           query: mutation
                         }

        json = JSON.parse(response.body, symbolize_names: true)
        user = json[:data][:updateUser][:currentUser]
        updated_location = json[:data][:updateUser][:currentUser][:location]


        compare_gql_and_db_users(user, @existing_user.reload)
        compare_gql_and_db_locations(updated_location, @existing_location.reload)
      end
    end

    it 'updates the user and location' do
      VCR.use_cassette('update_user_mutation_spec/update_user_and_location') do
        mutation = update_user_and_location_mutation

        post '/graphql', params: {
                           google_token: @existing_user.google_token,
                           query: mutation
                         }

        json = JSON.parse(response.body, symbolize_names: true)
        updated_user = json[:data][:updateUser][:currentUser]
        updated_location = json[:data][:updateUser][:currentUser][:location]

        compare_gql_and_db_users(updated_user, @existing_user.reload)
        compare_gql_and_db_locations(updated_location, @existing_location.reload)
      end
    end
  end

  describe 'with an invalid Google token' do
    it 'does not update anything' do
      mutation = update_user_and_location_mutation

      post '/graphql', params: {
                         google_token: 'invalidtoken',
                         query: mutation
                       }

      json = JSON.parse(response.body, symbolize_names: true)

      data = json[:data][:updateUser]
      error_message = json[:errors][0][:message]

      expect(data).to be_nil
      expect(error_message).to eq('Unauthorized - a valid google_token query parameter is required')
    end
  end

  def update_user_mutation
    "mutation {
      updateUser(
        user: {
          firstName: \"Henry\",
          lastName: \"Ford\",
          shortDesc: \"I like cars!\",
          longDesc: \"I could talk about it all day!\"
        }
      ) {
        currentUser {
          #{current_user_type_attributes}
          location {
            #{location_type_attributes}
          }
        }
      }
    }"
  end

  def update_location_mutation
    "mutation {
      updateUser(
        location: {
          streetAddress: \"15330 East 120th Place\",
          city: \"Commerce City\",
          state: \"CO\",
          zipCode: \"80022\"
        }
      ) {
        currentUser {
          #{current_user_type_attributes}
          location {
            #{location_type_attributes}
          }
        }
      }
    }"
  end

  def update_user_and_location_mutation
    "mutation {
      updateUser(
        user: {
          firstName: \"Henry\",
          lastName: \"Ford\",
          shortDesc: \"I like cars!\",
          longDesc: \"I could talk about it all day!\"
        },
        location: {
          streetAddress: \"15330 East 120th Place\",
          city: \"Commerce City\",
          state: \"CO\",
          zipCode: \"80022\"
        }
      ) {
        currentUser {
          #{current_user_type_attributes}
          location {
            #{location_type_attributes}
          }
        }
      }
    }"
  end
end
