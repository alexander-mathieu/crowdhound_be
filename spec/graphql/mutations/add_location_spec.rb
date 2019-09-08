require 'rails_helper'

RSpec.describe 'add location mutation', type: :request do
  before :each do
    @existing_user = create(:user)
  end

  it 'adds a location when a valid Google token is passed in' do

    mutation = add_location_mutation(@existing_user)

    post '/graphql', params: { query: mutation }

    json = JSON.parse(response.body, symbolize_names: true)

    data = json[:data][:addAddress]

    expect(data[:message]).to eq('Address successfully added')
  end

  it 'does not add a location if an invald Google token is passed in' do
    user = double(
      first_name: 'Bob',
      last_name: 'Smith II',
      email: 'bobsmithii@bs.com',
      google_token: 'thisisthesecondbesttoken',
    )

    mutation = add_location_mutation(user)

    post '/graphql', params: { query: mutation }

    json = JSON.parse(response.body, symbolize_names: true)

    data = json[:data][:addAddress]

    expect(data[:message]).to eq('No user found with that Google token')
  end

  def add_location_mutation(user)
    "mutation {
      addAddress(
        googleToken: \"#{user.google_token}\"
      ) {
        message
      }
    }"
  end
end
