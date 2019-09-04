module Types
  class LocationType < Types::BaseObject
    field :id, ID, null: false
    field :street_address, String, null: true
    field :city, String, null: true
    field :state, String, null: true
    field :zip_code, String, null: true
    field :lat, Float, null: true
    field :long, Float, null: true
  end
end
