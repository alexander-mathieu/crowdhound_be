require 'rails_helper'

RSpec.describe 'log out user mutation', type: :request do
  it 'logs out a user that is logged in' do
    user = create(:user)

    mutation = log_out_user_mutation(user)

    post '/graphql', params: { query: mutation }

    json = JSON.parse(response.body, symbolize_names: true)

    data = json[:data][:logOutUser]

    expect(data[:message]).to eq('User has been logged out')
  end

  it 'does not log out a user that is not logged in' do
    user = double(
      first_name: 'Bob',
      last_name: 'Smith IV',
      email: 'bobsmithiv@bs.com',
      google_token: 'notloggedin',
    )

    mutation = log_out_user_mutation(user)

    post '/graphql', params: { query: mutation }

    json = JSON.parse(response.body, symbolize_names: true)

    data = json[:data][:logOutUser]
    error_message = json[:errors][0][:message]

    expect(data).to be_nil
    expect(error_message).to eq('No user found with that Google token')
  end

  def log_out_user_mutation(user)
    "mutation {
      logOutUser(
        googleToken: \"#{user.google_token}\"
      ) {
        message
      }
    }"
  end
end
