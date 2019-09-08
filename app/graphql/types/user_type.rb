module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :first_name, String, null: true
    field :short_desc, String, null: true
    field :long_desc, String, null: true
    field :distance, Float, null: true
    field :dogs, [Types::DogType], null: true
    field :photos, [Types::PhotoType], null: true

    def distance
      current_user = context[:current_user]
      
      if current_user && current_user.location
        current_user.distance_to(object)
      else
        nil
      end
    end
  end
end
