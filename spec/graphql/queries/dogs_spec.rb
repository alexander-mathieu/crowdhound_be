require 'rails_helper'

RSpec.describe "dogs query", type: :request do
  it 'returns all dogs' do
    user1 = create(:user)
    dog11 = create(:dog, user: user1)
    user2 = create(:user)
    dog21, dog22 = create_list(:dog, 2, user: user2)
    photo = create(:photo, photoable: dog11)


    post '/graphql', params: { query: query }
    json = JSON.parse(response.body)
    data = json['data']['dogs']

    expect(data.count).to eq(3)

    first_gql_dog = data.first
    compare_gql_and_db_dogs(first_gql_dog, dog11)

    gql_user_of_first_dog = first_gql_dog['user']
    compare_gql_and_db_users(gql_user_of_first_dog, user1)

    gql_photos = first_gql_dog['photos']
    expect(gql_photos.count).to eq(1)
    compare_gql_and_db_photos(gql_photos.first, photo)
  end

  def query
    <<~GQL
      query {
        dogs {
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
end
