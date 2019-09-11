require 'rails_helper'

RSpec.describe 'chats query', type: :request do
  describe 'as an authenticated user' do
    it 'returns all chats' do
      u1, u2, u3 = create_list(:user, 3)

      params1 = {
        token: u1.token,
        query: start_chat_mutation(u2.id)
      }

      post '/graphql', params: params1

      params2 = {
        token: u1.token,
        query: start_chat_mutation(u3.id)
      }
      
      post '/graphql', params: params2
      
      params3 = {
        token: u1.token,
        query: query
      }

      post '/graphql', params: params3
  
      json = JSON.parse(response.body, symbolize_names: true)

      chats = json[:data][:chats]

      expect(chats.count).to eq(2)

      first_chat = chats[0]

      expect(first_chat).to have_key(:id)
      expect(first_chat).to have_key(:unreadCount)
      expect(first_chat).to have_key(:lastMessageAt)

      compare_gql_and_db_users(first_chat[:user], u2)
    end
  end

  describe 'as a visitor (without a valid api key)' do
    it 'returns null' do
      params = {
        token: 'not a real token',
        query: query
      }

      post '/graphql', params: params
  
      json = JSON.parse(response.body, symbolize_names: true)
      
      data = json[:data][:chats]
      expect(data).to be_nil
    end
  end

  def query
    <<~GQL
      query {
        chats {
          #{chat_type_attributes}
          user {
            #{user_type_attributes}
          }
        }
      }
    GQL
  end

  def start_chat_mutation(user_id)
    "mutation {
      startChat(userId: #{user_id}) {
        roomId
      }
    }"
  end
end
