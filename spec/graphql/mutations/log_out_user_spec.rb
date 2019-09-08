require 'rails_helper'

RSpec.describe 'logOutUser mutation', type: :request do
  it 'logs out a user that is logged in' do
    user = create(:user)

    mutation = log_out_user_mutation

    post '/graphql', params: { google_token: user.google_token, query: mutation }

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

    mutation = log_out_user_mutation

    post '/graphql', params: { google_token: user.google_token, query: mutation }

    json = JSON.parse(response.body, symbolize_names: true)

    data = json[:data][:logOutUser]
    error_message = json[:errors][0][:message]

    expect(data).to be_nil
    expect(error_message).to eq('Unauthorized - a valid google_token query parameter is required')
  end

  def log_out_user_mutation
    "mutation {
      logOutUser {
        message
      }
    }"
  end
end
