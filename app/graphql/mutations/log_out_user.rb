module Mutations
  class LogOutUser < BaseMutation
    null true

    argument :google_token, String, required: true

    field :message, String, null: true

    def resolve(google_token:)
      user = User.find_by(google_token: google_token)

      if user
        user.update(google_token: nil)

        { message: 'User has been logged out' }
      else
        raise GraphQL::ExecutionError, 'No user found with that Google token'
      end
    end
  end
end
