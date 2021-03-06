require 'rails_helper'

RSpec.describe 'users query', type: :request do
  it 'returns all users' do
    users = create_list(:user, 3)
    dogs = create_list(:dog, 2, user: users.first)
    photo = create(:photo, photoable: users.first)

    post '/graphql', params: { query: query }

    json = JSON.parse(response.body, symbolize_names: true)
    data = json[:data][:users]

    expect(data.count).to eq(3)

    first_gql_user = data.first
    first_db_user = users.first
    compare_gql_and_db_users(first_gql_user, first_db_user)

    gql_dogs = first_gql_user[:dogs]
    expect(gql_dogs.count).to eq(2)

    first_gql_dog = gql_dogs.first
    first_db_dog = dogs.first
    compare_gql_and_db_dogs(first_gql_dog, first_db_dog)

    gql_photos = first_gql_user[:photos]
    expect(gql_photos.count).to eq(1)
    compare_gql_and_db_photos(gql_photos.first, photo)
  end

  def query
    <<~GQL
      query {
        users {
          #{user_type_attributes}
          dogs {
            #{dog_type_attributes}
          }
          photos {
            #{photo_type_attributes}
          }
        }
      }
    GQL
  end
end
