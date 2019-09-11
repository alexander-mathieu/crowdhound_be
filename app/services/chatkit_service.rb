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

  def existing_chatkit_user
    begin
      conn.get_user({ id: @user.id.to_s })
    rescue => err
      if err.error_description == 'The requested user does not exist'
        nil
      else
        raise GraphQL::ExecutionError, err.message
      end
    end
  end

  def create_chatkit_user
    response = conn.create_user({ id: @user.id.to_s, name: @user.first_name })

    unless response[:status] == 201
      raise "Chatkit failed to create user. Response: #{response}"
    end
  end

  def get_token
    auth_data = conn.authenticate({
      user_id: @user.id.to_s
    })

    auth_data.body[:access_token] # token_type: bearer
  end

  def conn
    self.class.connect
  end
end
