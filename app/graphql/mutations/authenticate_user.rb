module Mutations
  class AuthenticateUser < BaseMutation
    null true

    argument :auth, Types::AuthenticationInput, required: true
    argument :api_key, String, required: true

    field :current_user, Types::CurrentUserType, null: true
    field :new, Boolean, null: true
    field :token, String, null: false

    def resolve(auth:, api_key:)
      unless api_key == ENV['EXPRESS_API_KEY']
        raise GraphQL::ExecutionError, 'Invalid API key'
      end

      user = User.find_or_initialize_by(
        email: auth[:email]
      )

      if user.new_record?
        user.first_name = auth[:first_name]
        user.last_name = auth[:last_name]
        new = true
      else
        new = false
      end

      token = SecureRandom.hex
      user.token = token
      user.save

      unless existing_chatkit_user(user)
        create_chatkit_user(user)
      end

      { current_user: user, new: new, token: token }
    end

    private

    def existing_chatkit_user(user)
      begin
        chatkit.get_user({ id: user.id.to_s })
      rescue => err
        if err.error_description != 'The requested user does not exist'
          raise GraphQL::ExecutionError, err.message
        end
      end
    end

    def create_chatkit_user(user)
      response = chatkit.create_user({ id: user.id.to_s, name: user.first_name })

      unless response[:status] == 201
        raise "Chatkit failed to create user. Response: #{response}"
      end
    end

    def chatkit
      @chatkit ||= ChatkitService.connect
    end
  end
end
