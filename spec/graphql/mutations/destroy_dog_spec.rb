require 'rails_helper'

RSpec.describe 'destroyDog mutation', type: :request do
  before :each do
    @user = create(:user)
    @d1, @d2 = create_list(:dog, 2, user: @user)
  end

  describe 'authenticated requests' do
    it 'destroys a dog associated with a user' do
      mutation = destroy_dog_mutation(@d1)

      post '/graphql', params: {
                         token: @user.token,
                         query: mutation
                       }

      json = JSON.parse(response.body, symbolize_names: true)

      data = json[:data][:destroyDog]

      expect(data[:message]).to eq('Dog successfully deleted')
      expect(@user.dogs.count).to eq(1)
    end

    it 'displays an error when no dog is found' do
      dog = create(:dog)

      mutation = destroy_dog_mutation(dog)

      post '/graphql', params: {
                         token: @user.token,
                         query: mutation
                       }

      json = JSON.parse(response.body, symbolize_names: true)

      data = json[:data][:destroyDog]
      error_message = json[:errors][0][:message]

      expect(data).to be_nil
      expect(error_message).to eq('Unauthorized')
      expect(@user.dogs.count).to eq(2)
    end
  end

  describe 'unauthenticated requests' do
    it 'displays an error message' do
      mutation = destroy_dog_mutation(@d1)

      post '/graphql', params: {
                         token: 'invalid token',
                         query: mutation
                       }

      json = JSON.parse(response.body, symbolize_names: true)

      data = json[:data][:destroyDog]
      error_message = json[:errors][0][:message]

      expect(data).to be_nil
      expect(error_message).to eq('Unauthorized - a valid token query parameter is required')
      expect(@user.dogs.count).to eq(2)
    end
  end

  def destroy_dog_mutation(dog)
    "mutation {
      destroyDog(dogId: #{dog.id}) {
        message
      }
    }"
  end
end
