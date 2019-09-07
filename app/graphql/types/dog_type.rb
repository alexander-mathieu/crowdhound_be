module Types
  class DogType < Types::BaseObject
    field :id, ID, null: false
    field :age, Float, null: true
    field :name, String, null: true
    field :breed, String, null: true
    field :birthdate, String, null: true
    field :weight, Int, null: true
    field :short_desc, String, null: true
    field :long_desc, String, null: true
    field :activity_level, Int, null: true
    field :distance, Float, null: true
    field :user, Types::UserType, null: true
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
