module Types
  module Inputs
    class LocationInput < BaseInputObject
      argument :street_address, String, required: false
      argument :city, String, required: false
      argument :state, String, required: false
      argument :zip_code, String, required: true
    end
  end
end
