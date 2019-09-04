require 'rails_helper'

RSpec.describe "users query", type: :request do
  it 'returns all users' do
    users = create_list(:user, 3)
    dogs = create_list(:dog, 2, user: users.first)

    post '/graphql', params: { query: query }
    json = JSON.parse(response.body, symbolize_names: true)
    data = json[:data][:users]

    expect(data.count).to eq(3)

    first_db_user = users.first
    compare_gql_and_db_users(data.first, first_db_user)

    actual_dogs = data.first[:dogs]
    expect(actual_dogs.count).to eq(2)

    first_gql_dog = actual_dogs.first
    first_db_dog = dogs.first
    compare_gql_and_db_dogs(first_gql_dog, first_db_dog)
  end

  def query
    <<~GQL
      query {
        users {
          #{user_type_attributes}
          dogs {
            #{dog_type_attributes}
          }
        }
      }
    GQL
  end
end
