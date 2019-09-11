module Types
  class MutationType < Types::BaseObject
    field :authenticate_user, mutation: Mutations::AuthenticateUser
    field :log_out_user, mutation: Mutations::LogOutUser
    field :updateUser, mutation: Mutations::UpdateUser

    field :create_location, mutation: Mutations::CreateLocation

    field :create_dog, mutation: Mutations::CreateDog
    field :destroy_dog, mutation: Mutations::DestroyDog

    field :create_photo, mutation: Mutations::CreatePhoto

    field :start_chat, mutation: Mutations::StartChat
  end
end
