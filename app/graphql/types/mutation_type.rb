module Types
  class MutationType < Types::BaseObject
    field :authenticate_user, mutation: Mutations::AuthenticateUser
  end
end
