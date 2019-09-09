require 'rails_helper'

RSpec.describe 'dog query', type: :request do
  describe 'as a visitor' do
    it 'returns a dog by id' do
      user = create(:user)
      dog = create(:dog, user: user)
      photo = create(:photo, photoable: dog)
  
      post '/graphql', params: { query: query(id: dog.id) }
  
      json = JSON.parse(response.body, symbolize_names: true)
      data = json[:data][:dog]
  
      compare_gql_and_db_dogs(data, dog)
      expect(data[:distance]).to be_nil
      
      gql_user = data[:user]
      compare_gql_and_db_users(gql_user, user)
      expect(gql_user[:distance]).to be_nil
  
      first_gql_photo = data[:photos].first
      compare_gql_and_db_photos(first_gql_photo, photo)
    end
  
    it 'has an error if no dog with that id' do
      dog = create(:dog)
  
      post '/graphql', params: { query: query(id: dog.id + 1) }
      json = JSON.parse(response.body, symbolize_names: true)
  
      error_message = json[:errors][0][:message]
      expect(error_message).to eq("Couldn't find Dog with 'id'=#{dog.id + 1}")
      
      data = json[:data]
      expect(data).to be_nil
    end
  end
  
  describe 'as an authenticated user' do
    before :each do
      VCR.use_cassette('authenticated_dog_query_spec/before_each') do
        @current_user = create(:user)

        Location.create!(
          user: @current_user,
          street_address: '1331 17th Street',
          city: 'Denver',
          state: 'CO',
          zip_code: '80202'
        )
      end
    end

    it 'returns a dog by id' do
      user = create(:user) # 0.89 miles away

      VCR.use_cassette('authenticated_dog_query_spec/other_user') do
        Location.create!(
          user: user,
          street_address: '494 East 19th Avenue',
          city: 'Denver',
          state: 'CO',
          zip_code: '80203'
        )
      end

      dog = create(:dog, user: user)
      photo = create(:photo, photoable: dog)
  
      make_authenticated_post_request(query(id: dog.id))
  
      json = JSON.parse(response.body, symbolize_names: true)
      data = json[:data][:dog]
  
      compare_gql_and_db_dogs(data, dog)
      expect(data[:distance]).to be_within(0.05).of(0.89)
  
      gql_user = data[:user]
      compare_gql_and_db_users(gql_user, user)
      expect(gql_user[:distance]).to be_within(0.05).of(0.89)
  
      first_gql_photo = data[:photos].first
      compare_gql_and_db_photos(first_gql_photo, photo)
    end
  
    it 'has an error if no dog with that id' do
      dog = create(:dog)
  
      make_authenticated_post_request(query(id: dog.id + 1))

      json = JSON.parse(response.body, symbolize_names: true)
  
      error_message = json[:errors][0][:message]
      expect(error_message).to eq("Couldn't find Dog with 'id'=#{dog.id + 1}")
      
      data = json[:data]
      expect(data).to be_nil
    end
  end

  def query(id:)
    <<~GQL
      query {
        dog(id: #{id}) {
          #{dog_type_attributes}
          user {
            #{user_type_attributes}
          }
          photos {
            #{photo_type_attributes}
          }
        }
      }
    GQL
  end

  def make_authenticated_post_request(query)
    post '/graphql', params: { token: @current_user.token, query: query }
  end
end
