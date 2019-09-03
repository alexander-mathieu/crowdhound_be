module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :first_name, String, null: true
    field :last_name, String, null: true
    field :email, String, null: true
    field :short_desc, String, null: true
    field :long_desc, String, null: true
    field :dogs, [Types::DogType], null: true
  end
end