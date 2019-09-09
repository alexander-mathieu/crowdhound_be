module Mutations
  class LogOutUser < BaseMutation
    null true

    field :message, String, null: true

    def resolve
      boot_unauthenticated_user

      context[:current_user].update(token: nil)

      { message: 'User has been logged out' }
    end
  end
end
