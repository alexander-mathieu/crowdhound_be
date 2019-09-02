module Types
  class DogType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: true
    field :breed, String, null: true
    field :birthdate, String, null: true
    field :weight, Int, null: true
    field :short_desc, String, null: true
    field :long_desc, String, null: true
    field :activity_level, Int, null: true
    field :user, [Types::UserType], null: true
  end
end
