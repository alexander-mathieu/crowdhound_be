require 'rails_helper'

RSpec.describe 'chats query', type: :request do
  describe 'as an authenticated user' do
    it 'returns all chats' do
      u1, u2, u3 = create_list(:user, 3)


  
      # post '/graphql', params: {
      #   token: u1.token
      #   query: query
      # }
  
      # json = JSON.parse(response.body, symbolize_names: true)
      # data = json[:data][:users]
  
      # expect(data.count).to eq(3)
  
      # first_gql_user = data.first
      # first_db_user = users.first
      # compare_gql_and_db_users(first_gql_user, first_db_user)
  
      # gql_dogs = first_gql_user[:dogs]
      # expect(gql_dogs.count).to eq(2)
  
      # first_gql_dog = gql_dogs.first
      # first_db_dog = dogs.first
      # compare_gql_and_db_dogs(first_gql_dog, first_db_dog)
  
      # gql_photos = first_gql_user[:photos]
      # expect(gql_photos.count).to eq(1)
      # compare_gql_and_db_photos(gql_photos.first, photo)
    end
  end

  def query
    <<~GQL
      query {
        chats {
          #{chat_type_attributes}
          user {
            #{user_type_attributes}
          }
        }
      }
    GQL
  end
end
