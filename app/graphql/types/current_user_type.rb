module Types
  class CurrentUserType < Types::UserType
    field :last_name, String, null: true
    field :email, String, null: true
    field :location, Types::LocationType, null: true
  end
end
