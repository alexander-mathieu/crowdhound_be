require 'rails_helper'

RSpec.describe 'createPhoto mutation', type: :request do
  describe 'as an authenticated user' do
    it 'creates a photo for the current_user' do
      user = create(:user)

      file = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/images/dog.jpg')))

      photo = Photo.new(photoable: user, caption: 'my great caption')

      params = {
        google_token: user.google_token,
        query: create_photo_mutation(photo),
        file: file
      }

      post '/graphql', params: params

      json = JSON.parse(response.body, symbolize_names: true)

      require 'pry'; binding.pry
      
      gql_photo = json[:data][:createPhoto][:photo]

      compare_gql_and_db_photos(gql_photo, photo, false)

      expect(user.photos.count).to eq(1)

      expect(gql_photo[:sourceUrl]).to be_a(String)
    end
  end

  describe 'as a visitor (not authenticated)' do
    xit 'does not create a photo of the user' do
      user = create(:user)

      caption = "my cute dog"
      file = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/images/dog.jpg')))

      params = {
        google_token: 'not a real google token',
        query: create_photo_mutation(user),
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

  def create_photo_mutation(photo)
    "mutation {
      createPhoto(
        photo: {
          photoableType: \"#{photo.photoable_type}\"
          photoableId: #{photo.photoable_id}
          caption: \"#{photo.caption}\"
        }
      ) {
        photo {
          #{photo_type_attributes}
        }
      }
    }"
  end
end
