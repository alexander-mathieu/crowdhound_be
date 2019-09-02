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

    expect(data.first).to include(
      'id'         => dog11.id.to_s,
      'name'       => dog11.name,
      'breed'      => dog11.breed,
      'weight'     => dog11.weight,
      'birthdate'  => dog11.birthdate.to_s,
      'shortDesc'  => dog11.short_desc,
      'longDesc'   => dog11.long_desc
    )

    actual_user = data.first['user']
    expect(actual_user).to include(
      'id'          => user1.id.to_s,
      'firstName'   => user1.first_name,
      'lastName'    => user1.last_name,
      'email'       => user1.email,
      'shortDesc'   => user1.short_desc,
      'longDesc'    => user1.long_desc
    )
  end

  def query
    <<~GQL
      query {
        dogs {
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
