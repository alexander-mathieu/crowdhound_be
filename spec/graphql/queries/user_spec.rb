require 'rails_helper'

RSpec.describe "user query", type: :request do
  it 'returns a user by id' do
    user = create(:user)
    dogs = create_list(:dog, 2, user: user)

    post '/graphql', params: { query: query(id: user.id) }
    json = JSON.parse(response.body)
    data = json['data']['user']

    compare_gql_and_db_users(data, user)

    actual_dogs = data['dogs']
    expect(actual_dogs.count).to eq(2)

    first_gql_dog = actual_dogs.first
    first_db_dog = user.dogs.first
    compare_gql_and_db_dogs(first_gql_dog, first_db_dog)
  end

  def query(id:)
    <<~GQL
      query {
        user(id: #{id}) {
          id
          firstName
          lastName
          email
          shortDesc
          longDesc
          dogs {
            id
            name
            breed
            weight
            birthdate
            shortDesc
            longDesc
          }
        }
      }
    GQL
  end
end
