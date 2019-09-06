module Mutations
  class AuthenticateUser < BaseMutation
    null true

    argument :auth, Types::AuthenticationInput, required: true
    argument :api_key, String, required: true

    field :current_user, Types::CurrentUserType, null: true

    def resolve(auth:, api_key:)
      return unless api_key == ENV['EXPRESS_API_KEY']

      user = User.find_or_create_by(
        email: auth[:email]
      )

      user.update(
        first_name: auth[:first_name],
        last_name:  auth[:last_name],
        google_token: auth[:token]
      )

      { current_user: user}
    end
  end
end
