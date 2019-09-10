require 'rails_helper'

RSpec.describe 'dogs query', type: :request do
  describe 'as a visitor' do
    before :each do
      mock_time = Time.parse('2019-07-07 11:45:00 -0600')
      allow(Time).to receive(:now).and_return(mock_time)

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

    it 'has an error when an incorrect range is passed to activityLevelRange' do
      query = query('activityLevelRange: [2]')

      post '/graphql', params: { query: query }

      json = JSON.parse(response.body, symbolize_names: true)

      error_message = json[:errors][0][:message]
      expect(error_message).to eq('Please provide an array with two integers for activityLevelRange.')

      data = json[:data]
      expect(data).to be_nil
    end

    it 'has an error when an incorrect range is passed to weightRange' do
      query = query('weightRange: [40]')

      post '/graphql', params: { query: query }

      json = JSON.parse(response.body, symbolize_names: true)

      error_message = json[:errors][0][:message]
      expect(error_message).to eq('Please provide an array with two integers for weightRange.')

      data = json[:data]
      expect(data).to be_nil
    end

    it 'has an error when an incorrect range is passed to ageRange' do
      query = query('ageRange: [2]')

      post '/graphql', params: { query: query }

      json = JSON.parse(response.body, symbolize_names: true)

      error_message = json[:errors][0][:message]
      expect(error_message).to eq('Please provide an array with two integers or floating point numbers for ageRange.')

      data = json[:data]
      expect(data).to be_nil
    end
  end

  describe 'as an authenticated user' do
    before :each do
      VCR.use_cassette('authenticated_dogs_query_spec/before_each') do
        mock_time = Time.parse('2019-07-07 11:45:00 -0600')
        allow(Time).to receive(:now).and_return(mock_time)

        @current_user = create(:user)
        Location.create!(
          user: @current_user,
          street_address: '1331 17th Street',
          city: 'Denver',
          state: 'CO',
          zip_code: '80202'
        )

        @u1 = create(:user) # 16.46 miles away
        Location.create!(
          user: @u1,
          street_address: '15330 East 120th Place',
          city: 'Commerce City',
          state: 'CO',
          zip_code: '80022'
        )
        @d1 = create(:dog, user: @u1, breed: 'Rat Terrier', activity_level: 0, birthdate: '2015-03-18', weight: 20)
        @d2 = create(:dog, user: @u1, breed: 'Malinois', activity_level: 1, birthdate: '2010-07-01' , weight: 60)
        @d3 = create(:dog, user: @u1, breed: 'Tibetan Terrier', activity_level: 2, birthdate: '2002-10-04', weight: 100)
        @p1 = create(:photo, photoable: @d1)

        @u2 = create(:user) # 0.89 miles away
        Location.create!(
          user: @u2,
          street_address: '494 East 19th Avenue',
          city: 'Denver',
          state: 'CO',
          zip_code: '80203'
        )
        @d4 = create(:dog, user: @u2, breed: 'Rat Terrier', activity_level: 0, birthdate: '2015-03-18', weight: 20)
        @d5 = create(:dog, user: @u2, breed: 'Malinois', activity_level: 1, birthdate: '2010-07-01', weight: 75)
        @d6 = create(:dog, user: @u2, breed: 'Tibetan Terrier', activity_level: 2, birthdate: '2003-10-04', weight: 100)

        @u3 = create(:user) # no location -- dogs won't appear
        @d7 = create(:dog, user: @u3, breed: 'Tibetan Terrier', activity_level: 0, birthdate: '2015-03-18', weight: 100)
      end
    end

    it 'returns dogs (that have a location) with their distances to the current user' do
      query = "query {
                 dogs {
                   #{dog_type_attributes}
                   distance
                   user {
                     #{user_type_attributes}
                   }
                   photos {
                     #{photo_type_attributes}
                   }
                 }
               }"

      make_authenticated_post_request(query)

      json = JSON.parse(response.body, symbolize_names: true)
      data = json[:data][:dogs]

      expect(data.count).to eq(6)

      first_gql_dog = data.first
      compare_gql_and_db_dogs(first_gql_dog, @d4)
      expect(first_gql_dog[:distance]).to be_within(0.05).of(0.89)

      gql_user_of_first_dog = first_gql_dog[:user]
      compare_gql_and_db_users(gql_user_of_first_dog, @u2)

      gql_photos = first_gql_dog[:photos]
      expect(gql_photos.count).to eq(0)
    end

    it 'returns dogs (that have a location) filtered by activity level' do
      query = query('activityLevelRange: [0, 1]')

      make_authenticated_post_request(query)

      json = JSON.parse(response.body, symbolize_names: true)
      data = json[:data][:dogs]

      expect(data.count).to eq(4)

      expect(data[0][:activityLevel]).to eq(0).or eq(1)
      expect(data[1][:activityLevel]).to eq(0).or eq(1)
      expect(data[2][:activityLevel]).to eq(0).or eq(1)
      expect(data[3][:activityLevel]).to eq(0).or eq(1)
    end

    it 'returns dogs (that have a location) filtered by weight' do
      query = query('weightRange: [60, 100]')

      make_authenticated_post_request(query)

      json = JSON.parse(response.body, symbolize_names: true)
      data = json[:data][:dogs]

      expect(data.count).to eq(4)

      expect(data[0][:weight]).to be_between(60, 100).inclusive
      expect(data[1][:weight]).to be_between(60, 100).inclusive
      expect(data[2][:weight]).to be_between(60, 100).inclusive
      expect(data[3][:weight]).to be_between(60, 100).inclusive
    end

    it 'returns dogs (that have a location) filtered by breed' do
      query = query("breed: [\"Rat Terrier\", \"Tibetan Terrier\"]")

      make_authenticated_post_request(query)

      json = JSON.parse(response.body, symbolize_names: true)
      data = json[:data][:dogs]

      expect(data.count).to eq(4)

      expect(data[0][:breed]).to eq('Rat Terrier').or eq('Tibetan Terrier')
      expect(data[1][:breed]).to eq('Rat Terrier').or eq('Tibetan Terrier')
      expect(data[2][:breed]).to eq('Rat Terrier').or eq('Tibetan Terrier')
      expect(data[3][:breed]).to eq('Rat Terrier').or eq('Tibetan Terrier')
    end

    it 'returns dogs (that have a location) filtered by age' do
      query = query('ageRange: [4, 10]')

      make_authenticated_post_request(query)

      json = JSON.parse(response.body, symbolize_names: true)
      data = json[:data][:dogs]

      expect(data.count).to eq(4)

      expect(data[0][:age]).to be_between(4, 10).inclusive
      expect(data[1][:age]).to be_between(4, 10).inclusive
      expect(data[2][:age]).to be_between(4, 10).inclusive
      expect(data[3][:age]).to be_between(4, 10).inclusive
    end

    it 'has an error when an incorrect range is passed to activityLevelRange' do
      query = query('activityLevelRange: [2]')

      make_authenticated_post_request(query)

      json = JSON.parse(response.body, symbolize_names: true)

      error_message = json[:errors][0][:message]
      expect(error_message).to eq('Please provide an array with two integers for activityLevelRange.')

      data = json[:data]
      expect(data).to be_nil
    end

    it 'has an error when an incorrect range is passed to weightRange' do
      query = query('weightRange: [40]')

      make_authenticated_post_request(query)

      json = JSON.parse(response.body, symbolize_names: true)

      error_message = json[:errors][0][:message]
      expect(error_message).to eq('Please provide an array with two integers for weightRange.')

      data = json[:data]
      expect(data).to be_nil
    end

    it 'has an error when an incorrect range is passed to ageRange' do
      query = query('ageRange: [2]')

      make_authenticated_post_request(query)

      json = JSON.parse(response.body, symbolize_names: true)

      error_message = json[:errors][0][:message]
      expect(error_message).to eq('Please provide an array with two integers or floating point numbers for ageRange.')

      data = json[:data]
      expect(data).to be_nil
    end

    describe 'returns dogs (that have a location) limited by maximum distance' do
      before :each do
        VCR.use_cassette('authenticated_dogs_query_spec/maximum_distance') do
          @u4 = create(:user) # 18.31 miles away
          Location.create!(
            user: @u4,
            street_address: '8500 Peña Boulevard',
            city: 'Denver',
            state: 'CO',
            zip_code: '80249'
          )
          @d8 = create(:dog, user: @u4)

          @u5 = create(:user) # 6.68 miles away
          Location.create!(
            user: @u5,
            street_address: '6000 Victory Way',
            city: 'Commerce City',
            state: 'CO',
            zip_code: '80022'
          )
          @d9 = create(:dog, user: @u5)

          @u6 = create(:user) # 1.33 miles away
          Location.create!(
            user: @u6,
            street_address: '1701 Bryant Street',
            city: 'Denver',
            state: 'CO',
            zip_code: '80204'
          )
          @d10 = create(:dog, user: @u6)

          def max_distance_query(argument)
            "query {
              dogs(#{argument}) {
                #{dog_type_attributes}
              }
            }"
          end
        end
      end

      it 'within 5 miles' do
        query = max_distance_query('maxDistance: 5')

        make_authenticated_post_request(query)

        json = JSON.parse(response.body, symbolize_names: true)
        dogs = json[:data][:dogs]

        expect(dogs.length).to eq(4)

        dogs.each do |dog|
          expect(dog[:distance]).to be < 5
        end
      end

      it 'within 10 miles' do
        query = max_distance_query('maxDistance: 10')

        make_authenticated_post_request(query)

        json = JSON.parse(response.body, symbolize_names: true)
        dogs = json[:data][:dogs]

        expect(dogs.length).to eq(5)

        dogs.each do |dog|
          expect(dog[:distance]).to be < 10
        end
      end

      it 'within 20 miles' do
        query = max_distance_query('maxDistance: 20')

        make_authenticated_post_request(query)

        json = JSON.parse(response.body, symbolize_names: true)
        dogs = json[:data][:dogs]

        expect(dogs.length).to eq(9)

        dogs.each do |dog|
          expect(dog[:distance]).to be < 20
        end
      end
    end
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

  def make_authenticated_post_request(query)
    post '/graphql', params: { token: @current_user.token, query: query }
  end
end
