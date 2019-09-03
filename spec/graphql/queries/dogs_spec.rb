require 'rails_helper'

RSpec.describe "dogs query", type: :request do
  it 'returns all dogs' do
    user1 = create(:user)
    dog11 = create(:dog, user: user1)
    user2 = create(:user)
    dog21 = create(:dog, user: user2)
    dog22 = create(:dog, user: user2)

    post '/graphql', params: { query: query }
    json = JSON.parse(response.body)
    data = json['data']['dogs']

    expect(data.count).to eq(3)
    compare_gql_and_db_dogs(data.first, dog11)

    actual_user = data.first['user']
    compare_gql_and_db_users(actual_user, user1)
  end

  def query
    <<~GQL
      query {
        dogs {
          #{dog_type_attributes}
          user {
            #{user_type_attributes}
          }
        }
      }
    GQL
  end
end
