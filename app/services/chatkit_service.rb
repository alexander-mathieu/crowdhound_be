require 'chatkit'

class ChatkitService
  def initialize(user)
    @user = user
  end

  def self.connect
    Chatkit::Client.new({
      instance_locator: ENV['CHATKIT_INSTANCE_LOCATOR'],
      key: ENV['CHATKIT_SECRET_KEY'],
    })
  end

  def existing_chatkit_user(user = @user)
    begin
      conn.get_user({ id: user.id.to_s })
    rescue => err
      if err.error_description == 'The requested user does not exist'
        nil
      else
        raise GraphQL::ExecutionError, err.message
      end
    end
  end

  def create_chatkit_user(user = @user)
    response = conn.create_user({ id: user.id.to_s, name: user.first_name })

    unless response[:status] == 201
      raise "Chatkit failed to create user. Response: #{response}"
    end
  end

  def find_or_create_chatkit_user(user = @user)
    existing_chatkit_user(user) || create_chatkit_user(user)
  end

  def get_token
    auth_data = conn.authenticate({
      user_id: @user.id.to_s
    })

    auth_data.body[:access_token] # token_type: bearer
  end

  def list_chats
    conn.get_user_rooms({ id: @user.id.to_s })
  end

  def find_or_create_room(other_user_id)
    participant_ids = [@user.id, other_user_id]

    room_id = "#{participant_ids.min}-#{participant_ids.max}"

    begin
      conn.get_room({
        id: room_id
      })
    rescue => err
      if err.error_description == 'The requested room does not exist'
        conn.create_room({
          id: room_id,
          creator_id: @user.id.to_s,
          name: room_id,
          user_ids: participant_ids.map(&:to_s),
          private: true
        })
      else
        raise GraphQL::ExecutionError, err.message
      end
    end
  end

  private

  def conn
    @conn ||= self.class.connect
  end
end
