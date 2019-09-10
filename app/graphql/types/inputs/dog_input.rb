module Types
  module Inputs
    class DogInput < BaseInputObject
      argument :name, String, required: true
      argument :activity_level, Integer, required: true
      argument :weight, Integer, required: true
      argument :breed, String, required: true
      argument :birthdate, String, required: true
      argument :short_desc, String, required: false
      argument :long_desc, String, required: false
    end
  end
end
