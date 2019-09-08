require 'rails_helper'

RSpec.describe 'createPhoto mutation', type: :request do
  describe 'as an authenticated user' do
    it 'creates a photo for the current_user' do
      user = create(:user)

      caption = "my cute dog"
      file = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/images/dog.jpg')))

      params = {
        google_token: user.google_token,
        query: create_photo_mutation(caption),
        file: file
      }

      post '/graphql', params: params

      json = JSON.parse(response.body, symbolize_names: true)
      
      gql_photo = json[:data][:createPhoto][:photo]
      expect(gql_photo[:caption]).to eq(caption)
      expect(gql_photo[:sourceUrl]).to be_a(String)

      expect(user.photos.count).to eq(1)
    end
  end

  describe 'as a visitor (not authenticated)' do
    it 'does not create a photo if the request is not authenticated' do
      user = create(:user)

      caption = "my cute dog"
      file = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/images/dog.jpg')))

      params = {
        google_token: 'not a real google token',
        query: create_photo_mutation(caption),
        file: file
      }

      post '/graphql', params: params

      json = JSON.parse(response.body, symbolize_names: true)

      data = json[:data][:createPhoto]
      error_message = json[:errors][0][:message]

      expect(data).to be_nil
      expect(error_message).to eq('Unauthorized - a valid google_token query parameter is required')

      expect(Photo.count).to eq(0)
    end
  end

  def create_photo_mutation(caption)
    "mutation {
      createPhoto(
        photo: {
          caption: \"#{caption}\"
        }
      ) {
        photo {
          #{photo_type_attributes}
        }
      }
    }"
  end
end
