require 'rails_helper'

RSpec.describe 'startChat mutation', type: :request do
  describe 'as an authenticated user' do
    it "creates a new chat with a particular user (if there isn't one already)" do
      user, other_user = create_list(:user, 2)

      params = {
        token: user.token,
        query: start_chat_mutation(other_user.id)
      }
  
      post '/graphql', params: params
  
      json = JSON.parse(response.body, symbolize_names: true)

      gql_room_id = json[:data][:startChat][:roomId]
      expected_room_id = "#{user.id.to_s}-#{other_user.id.to_s}"
  
      expect(gql_room_id).to eq(expected_room_id)
    end
  end

  describe 'as a visitor (not authenticated)' do
    it 'does not create a new chat' do
      user, other_user = create_list(:user, 2)

      params = {
        token: 'not a real token',
        query: start_chat_mutation(other_user.id)
      }
  
      post '/graphql', params: params
  
      json = JSON.parse(response.body, symbolize_names: true)
  
      error_message = json[:errors][0][:message]
      expect(error_message).to eq('Unauthorized - a valid token query parameter is required')
      
      data = json[:data][:startChat]
      expect(data).to be_nil
    end
  end

  def start_chat_mutation(user_id)
    "mutation {
      startChat(userId: #{user_id}) {
        roomId
      }
    }"
  end
end
