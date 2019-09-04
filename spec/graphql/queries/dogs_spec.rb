require 'rails_helper'

RSpec.describe 'dogs query', type: :request do
  before :each do
    @u1 = create(:user)
    @d1 = create(:dog, user: @u1, breed: 'Rat Terrier', activity_level: 0, birthdate: '2015-03-18', weight: 20)
    @d2 = create(:dog, user: @u1, breed: 'Malinois', activity_level: 1, birthdate: '2010-07-01' , weight: 60)
    @d3 = create(:dog, user: @u1, breed: 'Tibetan Terrier', activity_level: 2, birthdate: '2002-10-04', weight: 100)
    @p1 = create(:photo, photoable: @d1)

    @u2 = create(:user)
    @d4 = create(:dog, user: @u2, breed: 'Rat Terrier', activity_level: 0, birthdate: '2015-03-18', weight: 20)
    @d5 = create(:dog, user: @u2, breed: 'Malinois', activity_level: 1, birthdate: '2010-07-01', weight: 75)
    @d6 = create(:dog, user: @u2, breed: 'Tibetan Terrier', activity_level: 2, birthdate: '2003-10-04', weight: 100)
  end

  it 'returns all dogs' do
    query = "query {
               dogs {
                 #{dog_type_attributes}
                 user {
                   #{user_type_attributes}
                 }
                 photos {
                   #{photo_type_attributes}
                 }
               }
             }"

    post '/graphql', params: { query: query }

    json = JSON.parse(response.body, symbolize_names: true)
    data = json[:data][:dogs]

    expect(data.count).to eq(6)

    first_gql_dog = data.first
    compare_gql_and_db_dogs(first_gql_dog, @d1)

    gql_user_of_first_dog = first_gql_dog[:user]
    compare_gql_and_db_users(gql_user_of_first_dog, @u1)

    gql_photos = first_gql_dog[:photos]
    expect(gql_photos.count).to eq(1)
    compare_gql_and_db_photos(gql_photos.first, @p1)
  end

  it 'returns all dogs filtered by activity level' do
    query = query('activityLevelRange: [0, 1]')

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
    query = query('weightRange: [60, 100]')

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
    query = query("breed: [\"Rat Terrier\", \"Tibetan Terrier\"]")

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
    query = query('ageRange: [4, 10]')

    post '/graphql', params: { query: query }

    json = JSON.parse(response.body, symbolize_names: true)
    data = json[:data][:dogs]

    expect(data.count).to eq(4)

    expect(data[0][:age]).to be_between(4, 10).inclusive
    expect(data[1][:age]).to be_between(4, 10).inclusive
    expect(data[2][:age]).to be_between(4, 10).inclusive
    expect(data[3][:age]).to be_between(4, 10).inclusive
  end

  it 'raises an exception when an incorrect range is passed to activityLevelRange' do
    query = query('activityLevelRange: [2]')

    post '/graphql', params: { query: query }

    json = JSON.parse(response.body, symbolize_names: true)
    error_message = json[:errors][0][:message]

    expect(error_message).to eq('Please provide an array with two integers for activityLevelRange.')
  end

  it 'raises an exception when an incorrect range is passed to weightRange' do
    query = query('weightRange: [40]')

    post '/graphql', params: { query: query }

    json = JSON.parse(response.body, symbolize_names: true)
    error_message = json[:errors][0][:message]

    expect(error_message).to eq('Please provide an array with two integers for weightRange.')
  end

  it 'raises an exception when an incorrect range is passed to ageRange' do
    query = query('ageRange: [2]')

    post '/graphql', params: { query: query }

    json = JSON.parse(response.body, symbolize_names: true)
    error_message = json[:errors][0][:message]

    expect(error_message).to eq('Please provide an array with two integers or floating point numbers for ageRange.')
  end

  def query(argument)
    "query {
      dogs(#{argument}) {
        #{dog_type_attributes}
        user {
          #{user_type_attributes}
        }
        photos {
          #{photo_type_attributes}
        }
      }
    }"
  end
end
