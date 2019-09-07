require 'rails_helper'

RSpec.describe "createUser mutation", type: :request do
  xit 'returns a user upon successful creation' do
    first_name = "Bob"
    last_name = "Smith"
    email = "bob@smith.com"
    short_desc = "my name is bob!"
    long_desc = "ldjflskjfdalsdjfalskjdflsjkdflkjsd sfd sklajdfalsdkjf a dsfalsj. asd fjladskjfa."

    query = "
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
    "

    post '/graphql', params: { query: query }
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

  xit 'throws an error if the email is already taken' do
    first_name = "Bob"
    last_name = "Smith"
    email = "bob@smith.com"
    short_desc = "my name is bob!"
    long_desc = "ldjflskjfdalsdjfalskjdflsjkdflkjsd sfd sklajdfalsdkjf a dsfalsj. asd fjladskjfa."

    create(:user, email: email)

    query = "
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
    "

    expect { post '/graphql', params: { query: query } }
    .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Email has already been taken")

    expect(User.count).to eq(1)
  end

  xit 'returns an error if no firstName, lastName, and/or email is entered' do
    query = "
    mutation {
      createUser() {
        #{user_type_attributes}
      }
    }
    "

    post '/graphql', params: { query: query }
    json = JSON.parse(response.body, symbolize_names: true)

    error_message = json[:errors].first[:message]
    expect(error_message).to eq("Field 'createUser' is missing required arguments: firstName, lastName, email")

    expect(json[:data]).to be_nil

    expect(User.count).to eq(0)
  end
end
