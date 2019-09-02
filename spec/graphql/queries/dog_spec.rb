require 'rails_helper'

RSpec.describe "dog query", type: :request do
  it 'returns a dog by id' do
    user = create(:user)
    dog = create(:dog, user: user)

    post '/graphql', params: { query: query(id: dog.id) }
    json = JSON.parse(response.body)
    data = json['data']['dog']

    expect(data).to include(
      'id'         => dog.id.to_s,
      'name'       => dog.name,
      'breed'      => dog.breed,
      'weight'     => dog.weight,
      'birthdate'  => dog.birthdate.to_s,
      'shortDesc'  => dog.short_desc,
      'longDesc'   => dog.long_desc
    )

    actual_user = data['user']
    expect(actual_user).to include(
      'id'          => user.id.to_s,
      'firstName'   => user.first_name,
      'lastName'    => user.last_name,
      'email'       => user.email,
      'shortDesc'   => user.short_desc,
      'longDesc'    => user.long_desc
    )
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
