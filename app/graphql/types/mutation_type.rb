module Types
  class MutationType < Types::BaseObject
    field :authenticate_user, mutation: Mutations::AuthenticateUser
    field :log_out_user, mutation: Mutations::LogOutUser

    field :create_location, mutation: Mutations::CreateLocation
    field :create_dog, mutation: Mutations::CreateDog
    field :create_photo, mutation: Mutations::CreatePhoto

    field :updateUser, mutation: Mutations::UpdateUser
  end
end
