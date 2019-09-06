module Types
  class CurrentUserType < Types::BaseObject
    field :id, ID, null: false
    field :first_name, String, null: true
    field :last_name, String, null: true
    field :email, String, null: true
    field :short_desc, String, null: true
    field :long_desc, String, null: true
    field :dogs, [Types::DogType], null: true
    field :photos, [Types::PhotoType], null: true
    field :location, Types::LocationType, null: true
  end
end
