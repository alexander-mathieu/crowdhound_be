require 'rails_helper'


RSpec.describe 'createPhoto mutation', type: :request do
  describe 'as an authenticated user' do
    before(:each) do
      @user = create(:user)
  
      @file = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/images/dog.jpg')))
    end

    it 'creates a photo for the current_user' do
      photo = Photo.new(photoable: @user, caption: 'my great caption')

      params = {
        token: @user.token,
        query: create_photo_mutation(photo),
        file: @file
      }

      post '/graphql', params: params

      json = JSON.parse(response.body, symbolize_names: true)

      gql_photo = json[:data][:createPhoto][:photo]

      compare_gql_and_db_photos(gql_photo, photo, false)

      expect(@user.photos.count).to eq(1)

      expect(gql_photo[:sourceUrl]).to be_a(String)
    end

    it 'does not create a photo for a different user' do
      other_user = create(:user)
      photo = Photo.new(photoable: other_user, caption: 'my great caption')

      params = {
        token: @user.token,
        query: create_photo_mutation(photo),
        file: @file
      }

      post '/graphql', params: params

      json = JSON.parse(response.body, symbolize_names: true)

      data = json[:data][:createPhoto]
      error_message = json[:errors][0][:message]

      expect(data).to be_nil
      expect(error_message).to eq('Unauthorized')

      expect(Photo.count).to eq(0)
    end

    it 'returns an error if no user is found with that id' do
      photo = Photo.new(photoable_id: @user.id + 1, photoable_type: 'User', caption: 'my great caption')

      params = {
        token: @user.token,
        query: create_photo_mutation(photo),
        file: @file
      }

      post '/graphql', params: params

      json = JSON.parse(response.body, symbolize_names: true)

      data = json[:data][:createPhoto]
      error_message = json[:errors][0][:message]

      expect(data).to be_nil
      expect(error_message).to eq('Unauthorized')

      expect(Photo.count).to eq(0)
    end
    
    it "creates a photo for the current_user's dog" do
      dog = create(:dog, user: @user)
      
      photo = Photo.new(photoable: dog, caption: 'my great caption')
      
      params = {
        token: @user.token,
        query: create_photo_mutation(photo),
        file: @file
      }
      
      post '/graphql', params: params
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      gql_photo = json[:data][:createPhoto][:photo]
      
      compare_gql_and_db_photos(gql_photo, photo, false)
      
      expect(dog.photos.count).to eq(1)
      
      expect(gql_photo[:sourceUrl]).to be_a(String)
    end
    
    it "does not create a photo for a different user's dog" do
      other_user = create(:user)
      dog = create(:dog, user: other_user)
      photo = Photo.new(photoable: dog, caption: 'my great caption')

      params = {
        token: @user.token,
        query: create_photo_mutation(photo),
        file: @file
      }

      post '/graphql', params: params

      json = JSON.parse(response.body, symbolize_names: true)

      data = json[:data][:createPhoto]
      error_message = json[:errors][0][:message]

      expect(data).to be_nil
      expect(error_message).to eq('Unauthorized')

      expect(Photo.count).to eq(0)
    end
  end

  describe 'as a visitor (not authenticated)' do
    xit 'does not create a photo of the user' do
      user = create(:user)

      caption = "my cute dog"
      file = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/images/dog.jpg')))

      params = {
        token: 'not a real token',
        query: create_photo_mutation(user),
        file: file
      }

      post '/graphql', params: params

      json = JSON.parse(response.body, symbolize_names: true)

      data = json[:data][:createPhoto]
      error_message = json[:errors][0][:message]

      expect(data).to be_nil
      expect(error_message).to eq('Unauthorized - a valid token query parameter is required')

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

VCR.turn_on!
