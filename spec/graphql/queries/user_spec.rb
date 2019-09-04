require 'rails_helper'

RSpec.describe "user query", type: :request do
  it 'returns a user by id' do
    user = create(:user)
    dogs = create_list(:dog, 2, user: user)
    create(:photo, photoable: dogs.first)
    photo = create(:photo, photoable: user)

    post '/graphql', params: { query: query(id: user.id) }
    json = JSON.parse(response.body)
    data = json['data']['user']

    compare_gql_and_db_users(data, user)

    actual_dogs = data['dogs']
    expect(actual_dogs.count).to eq(2)

    first_gql_dog = actual_dogs.first
    first_db_dog = user.dogs.first
    compare_gql_and_db_dogs(first_gql_dog, first_db_dog)

    first_gql_photo = data['photos'].first
    compare_gql_and_db_photos(first_gql_photo, photo)
  end

  it 'raises exception if no user with that id' do
    user = create(:user)

    expect { post '/graphql', params: { query: query(id: user.id + 1) } }
    .to raise_error(ActiveRecord::RecordNotFound, "Couldn't find User with 'id'=#{user.id + 1}")
  end

  def query(id:)
    <<~GQL
      query {
        user(id: #{id}) {
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
