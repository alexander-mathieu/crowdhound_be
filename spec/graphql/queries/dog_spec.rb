require 'rails_helper'

RSpec.describe "dog query", type: :request do
  it 'returns a dog by id' do
    user = create(:user)
    dog = create(:dog, user: user)

    post '/graphql', params: { query: query(id: dog.id) }
    json = JSON.parse(response.body)
    data = json['data']['dog']

    compare_gql_and_db_dogs(data, dog)
    
    actual_user = data['user']
    compare_gql_and_db_users(actual_user, user)
  end

  def query(id:)
    <<~GQL
      query {
        dog(id: #{id}) {
          id
          name
          breed
          weight
          birthdate
          shortDesc
          longDesc
          user {
            id
            firstName
            lastName
            email
            shortDesc
            longDesc
          }
        }
      }
    GQL
  end
end
