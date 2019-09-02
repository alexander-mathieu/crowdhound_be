require 'rails_helper'

RSpec.describe "user query", type: :request do
  it 'returns a user by id' do
    user = create(:user)
    dogs = create_list(:dog, 2, user: user)

    post '/graphql', params: { query: query(id: user.id) }
    json = JSON.parse(response.body)
    data = json['data']['user']

    expect(data).to include(
      'id'          => user.id.to_s,
      'firstName'   => user.first_name,
      'lastName'    => user.last_name,
      'email'       => user.email,
      'shortDesc'   => user.short_desc,
      'longDesc'    => user.long_desc
    )

    actual_dogs = data['dogs']
    expect(actual_dogs.count).to eq(2)

    first_dog = actual_dogs.first
    expect(first_dog).to include(
      'id'         => user.dogs.first.id.to_s,
      'name'       => user.dogs.first.name,
      'breed'      => user.dogs.first.breed,
      'weight'     => user.dogs.first.weight,
      'birthdate'  => user.dogs.first.birthdate.to_s,
      'shortDesc'  => user.dogs.first.short_desc,
      'longDesc'   => user.dogs.first.long_desc
    )
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
