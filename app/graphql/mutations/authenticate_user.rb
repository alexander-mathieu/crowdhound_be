module Mutations
  class AuthenticateUser < BaseMutation
    null true

    argument :auth, Types::AuthenticationInput, required: true
    argument :api_key, String, required: true

    field :current_user, Types::CurrentUserType, null: true
    field :new, Boolean, null: true

    def resolve(auth:, api_key:)
      unless api_key == ENV['EXPRESS_API_KEY']
        raise GraphQL::ExecutionError, 'Invalid API key'
      end

      user = User.find_or_initialize_by(
        email: auth[:email]
      )

      user.new_record? ? new = true : new = false

      user.first_name = auth[:first_name]
      user.last_name = auth[:last_name]
      user.google_token = auth[:google_token]

      user.save

      { current_user: user, new: new }
    end
  end
end
