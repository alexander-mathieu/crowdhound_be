require 'rails_helper'

RSpec.describe "createUser mutation", type: :request do
  it 'returns a user upon successful creation' do
    first_name = "Bob"
    last_name = "Smith"
    email = "bob@smith.com"
    short_desc = "my name is bob!"
    long_desc = "ldjflskjfdalsdjfalskjdflsjkdflkjsd sfd sklajdfalsdkjf a dsfalsj. asd fjladskjfa."

    post '/graphql', params: { query: query(first_name: first_name, last_name: last_name, email: email, short_desc: short_desc, long_desc: long_desc) }
    json = JSON.parse(response.body)

    data = json['data']['createUser']

    expect(data).to have_key("id")

    expect(data).to include(
      'firstName'   => first_name,
      'lastName'    => last_name,
      'email'       => email,
      'shortDesc'   => short_desc,
      'longDesc'    => long_desc
    )

    expect(User.count).to eq(1)
  end

  # it 'raises exception if no user with that id' do
  #   user = create(:user)

  #   expect { post '/graphql', params: { query: query(id: user.id + 1) } }
  #   .to raise_error(ActiveRecord::RecordNotFound, "Couldn't find User with 'id'=#{user.id + 1}")
  # end

  def query(first_name:, last_name:, email:, short_desc: nil, long_desc: nil)
    <<~GQL
      mutation {
        createUser(
          firstName: \"#{first_name}\",
          lastName: \"#{last_name}\",
          email: \"#{email}\",
          shortDesc: \"#{short_desc}\",
          longDesc: \"#{long_desc}\"
        ) {
          #{user_type_attributes}
        }
      }
    GQL
  end
end
