module Types
  class MutationType < Types::BaseObject
    field :createUser, mutation: Mutations::CreateUser # TODO remove
    field :authenticate_user, mutation: Mutations::AuthenticateUser
  end
end
