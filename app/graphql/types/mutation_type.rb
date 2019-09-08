module Types
  class MutationType < Types::BaseObject
    field :authenticate_user, mutation: Mutations::AuthenticateUser
    field :log_out_user, mutation: Mutations::LogOutUser
    field :add_location, mutation: Mutations::AddLocation
  end
end
