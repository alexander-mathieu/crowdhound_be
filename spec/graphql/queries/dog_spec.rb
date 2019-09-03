require 'rails_helper'

RSpec.describe "dog query", type: :request do
  it 'returns a dog by id' do
    user = create(:user)
    dog = create(:dog, user: user)
    photo = create(:photo, photoable: dog)

    post '/graphql', params: { query: query(id: dog.id) }
    json = JSON.parse(response.body)
    data = json['data']['dog']

    compare_gql_and_db_dogs(data, dog)
    
    gql_user = data['user']
    compare_gql_and_db_users(gql_user, user)
    
    first_gql_photo = data['photos'].first
    compare_gql_and_db_photos(first_gql_photo, photo)
  end

  it 'raises exception if no dog with that id' do
    dog = create(:dog)

    expect { post '/graphql', params: { query: query(id: dog.id + 1) } }
    .to raise_error(ActiveRecord::RecordNotFound, "Couldn't find Dog with 'id'=#{dog.id + 1}")
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
end
