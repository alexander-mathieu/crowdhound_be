require 'rails_helper'

RSpec.describe 'current_user query', type: :request do
  it 'returns the current user (based on the token in the Authorization header)' do
    VCR.use_cassette('current_user_query_location_create') do
      user = create(:user)
      dogs = create_list(:dog, 2, user: user)
      photo = create(:photo, photoable: user)

      location = Location.create!(
        user: user,
        street_address: '1331 17th Street',
        city: 'Denver',
        state: 'CO',
        zip_code: '80202'
      )

      params = { 
        query: query,
        google_token: user.google_token
      }

      post '/graphql', params: params

      json = JSON.parse(response.body, symbolize_names: true)

      gql_user = json[:data][:currentUser]
      compare_gql_and_db_users(gql_user, user)

      gql_dogs = gql_user[:dogs]
      expect(gql_dogs.count).to eq(2)

      first_gql_dog = gql_dogs.first
      first_db_dog = dogs.first
      compare_gql_and_db_dogs(first_gql_dog, first_db_dog)

      gql_photos = gql_user[:photos]
      expect(gql_photos.count).to eq(1)
      compare_gql_and_db_photos(gql_photos.first, photo)

      gql_location = gql_user[:location]
      compare_gql_and_db_locations(gql_location, location)
    end
  end

  def query
    <<~GQL
      query {
        currentUser {
          #{current_user_type_attributes}
          dogs {
            #{dog_type_attributes}
          }
          photos {
            #{photo_type_attributes}
          }
          location {
            #{location_type_attributes}
          }
        }
      }
    GQL
  end
end
