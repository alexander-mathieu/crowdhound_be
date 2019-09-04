require 'rails_helper'

RSpec.describe 'dogs query', type: :request do
  before :each do
    @u1 = create(:user)
    @d1 = create(:dog, user: @u1, breed: 'Rat Terrier', activity_level: 0, birthdate: '2015-03-18', weight: 20)
    @d2 = create(:dog, user: @u1, breed: 'Malinois', activity_level: 1, birthdate: '2010-07-01' , weight: 60)
    @d3 = create(:dog, user: @u1, breed: 'Tibetan Terrier', activity_level: 2, birthdate: '2002-10-04', weight: 100)

    @u2 = create(:user)
    @d4 = create(:dog, user: @u2, breed: 'Rat Terrier', activity_level: 0, birthdate: '2015-03-18', weight: 20)
    @d5 = create(:dog, user: @u2, breed: 'Malinois', activity_level: 1, birthdate: '2010-07-01', weight: 60)
    @d6 = create(:dog, user: @u2, breed: 'Tibetan Terrier', activity_level: 2, birthdate: '2003-10-04', weight: 100)
  end

  it 'returns all dogs' do
    query = "query { dogs { #{dog_type_attributes} user { #{user_type_attributes} }}}"

    post '/graphql', params: { query: query }

    json = JSON.parse(response.body, symbolize_names: true)
    data = json[:data][:dogs]

    expect(data.count).to eq(6)
    compare_gql_and_db_dogs(data.first, @d1)

    actual_user = data.first[:user]
    compare_gql_and_db_users(actual_user, @u1)
  end

  it 'returns all dogs filtered by activity level' do
    query = "query { dogs(activityLevelRange: [0, 1]) { #{dog_type_attributes} user { #{user_type_attributes} }}}"

    post '/graphql', params: { query: query }

    json = JSON.parse(response.body, symbolize_names: true)
    data = json[:data][:dogs]

    expect(data.count).to eq(4)

    expect(data[0][:activityLevel]).to eq(0).or eq(1)
    expect(data[1][:activityLevel]).to eq(0).or eq(1)
    expect(data[2][:activityLevel]).to eq(0).or eq(1)
    expect(data[3][:activityLevel]).to eq(0).or eq(1)
  end

  it 'returns all dogs filtered by weight' do
    query = "query { dogs(weightRange: [60, 100]) { #{dog_type_attributes} user { #{user_type_attributes} }}}"

    post '/graphql', params: { query: query }

    json = JSON.parse(response.body, symbolize_names: true)
    data = json[:data][:dogs]

    expect(data.count).to eq(4)

    expect(data[0][:weight]).to be_between(60, 100).inclusive
    expect(data[1][:weight]).to be_between(60, 100).inclusive
    expect(data[2][:weight]).to be_between(60, 100).inclusive
    expect(data[3][:weight]).to be_between(60, 100).inclusive
  end

  it 'returns all dogs filtered by breed' do
    query = "query { dogs(breed: [\"Rat Terrier\", \"Tibetan Terrier\"]) { #{dog_type_attributes} user { #{user_type_attributes} }}}"

    post '/graphql', params: { query: query }

    json = JSON.parse(response.body, symbolize_names: true)
    data = json[:data][:dogs]

    expect(data.count).to eq(4)

    expect(data[0][:breed]).to eq('Rat Terrier').or eq('Tibetan Terrier')
    expect(data[1][:breed]).to eq('Rat Terrier').or eq('Tibetan Terrier')
    expect(data[2][:breed]).to eq('Rat Terrier').or eq('Tibetan Terrier')
    expect(data[3][:breed]).to eq('Rat Terrier').or eq('Tibetan Terrier')
  end

  it 'returns all dogs filtered by age' do
    query = "query { dogs(ageRange: [4, 10]) { #{dog_type_attributes} user { #{user_type_attributes} }}}"

    post '/graphql', params: { query: query }

    json = JSON.parse(response.body, symbolize_names: true)
    data = json[:data][:dogs]

    expect(data.count).to eq(4)

    expect(data[0][:age]).to be_between(4, 10).inclusive
    expect(data[1][:age]).to be_between(4, 10).inclusive
    expect(data[2][:age]).to be_between(4, 10).inclusive
    expect(data[3][:age]).to be_between(4, 10).inclusive
  end

  it 'raises an exception when an incorrect range is passed to a filter' do
    activity_level_query = "query { dogs(activityLevelRange: [1]) { #{dog_type_attributes} user { #{user_type_attributes} }}}"

    expect { post '/graphql', params: { query: activity_level_query } }
    .to raise_error(RuntimeError, 'Please provide an array with two integers.')

    weight_query = "query { dogs(weightRange: [100]) { #{dog_type_attributes} user { #{user_type_attributes} }}}"

    expect { post '/graphql', params: { query: weight_query } }
    .to raise_error(RuntimeError, 'Please provide an array with two integers.')

    age_query = "query { dogs(ageRange: [10]) { #{dog_type_attributes} user { #{user_type_attributes} }}}"

    expect { post '/graphql', params: { query: age_query } }
    .to raise_error(RuntimeError, 'Please provide an array with two integers or floating point numbers.')
  end
end
