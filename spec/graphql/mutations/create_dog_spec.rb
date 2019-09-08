require 'rails_helper'

RSpec.describe 'createDog mutation', type: :request do
  describe 'as an authenticated user' do
    it 'creates a dog for the current_user' do
      user = create(:user)
  
      dog_template = Dog.new(
        name: 'Fluffy',
        activity_level: 1,
        weight: 10,
        breed: 'Miniature Poodle',
        birthdate: '2018/08/01',
        short_desc: 'Playful little pup',
        long_desc: 'What else could you possibly want to know?'
      )
  
      params = {
        google_token: user.google_token,
        query: create_dog_mutation(dog_template)
      }
  
      post '/graphql', params: params
  
      json = JSON.parse(response.body, symbolize_names: true)
  
      gql_dog = json[:data][:createDog][:dog]
  
      compare_gql_and_db_dogs(gql_dog, dog_template, false)
  
      expect(user.dogs.count).to eq(1)
    end
  end

  describe 'as a visitor (not authenticated)' do
    it 'does not create a dog' do
      dog_template = Dog.new(
        name: 'Fluffy',
        activity_level: 1,
        weight: 10,
        breed: 'Miniature Poodle',
        birthdate: '2018/08/01',
        short_desc: 'Playful little pup',
        long_desc: 'What else could you possibly want to know?'
      )
  
      params = {
        google_token: 'not a real google token',
        query: create_dog_mutation(dog_template)
      }
  
      post '/graphql', params: params
  
      json = JSON.parse(response.body, symbolize_names: true)
  
      data = json[:data][:createDog]
      error_message = json[:errors][0][:message]
  
      expect(data).to be_nil
      expect(error_message).to eq('Unauthorized - a valid google_token query parameter is required')
  
      expect(Dog.count).to eq(0)
    end
  end

  def create_dog_mutation(dog_template)
    "mutation {
      createDog(
        dog: {
          name: \"#{dog_template.name}\"
          activityLevel: #{dog_template.activity_level}
          weight: #{dog_template.weight}
          breed: \"#{dog_template.breed}\"
          birthdate: \"#{dog_template.birthdate}\"
          shortDesc: \"#{dog_template.short_desc}\"
          longDesc: \"#{dog_template.long_desc}\"
        }
      ) {
        dog {
          #{dog_type_attributes}
        }
      }
    }"
  end
end
