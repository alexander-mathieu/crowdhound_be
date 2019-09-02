require 'rails_helper'

RSpec.describe "users query", type: :request do
  it 'returns all users' do
    users = create_list(:user, 3)
    dogs = create_list(:dog, 2, user: users.first)

    post '/graphql', params: { query: query }
    json = JSON.parse(response.body)
    data = json['data']['users']

    expect(data.count).to eq(3)

    first_user = users.first

    expect(data.first).to include(
      'id'          => first_user.id.to_s,
      'firstName'   => first_user.first_name,
      'lastName'    => first_user.last_name,
      'email'       => first_user.email,
      'shortDesc'   => first_user.short_desc,
      'longDesc'    => first_user.long_desc
    )

    actual_dogs = data.first['dogs']
    expect(actual_dogs.count).to eq(2)

    first_actual_dog = actual_dogs.first
    expect(first_actual_dog).to include(
      'id'         => dogs.first.id.to_s,
      'name'       => dogs.first.name,
      'breed'      => dogs.first.breed,
      'weight'     => dogs.first.weight,
      'birthdate'  => dogs.first.birthdate.to_s,
      'shortDesc'  => dogs.first.short_desc,
      'longDesc'   => dogs.first.long_desc
    )
  end

  def query
    <<~GQL
      query {
        users {
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
