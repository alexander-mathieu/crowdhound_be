module Types
  class MutationType < Types::BaseObject
    field :authenticate_user, mutation: Mutations::AuthenticateUser
    field :add_location, mutation: Mutations::AddLocation
  end
end
