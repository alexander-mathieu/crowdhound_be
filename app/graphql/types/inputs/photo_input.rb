module Types
  module Inputs
    class PhotoInput < BaseInputObject
      argument :photoable_type, String, required: true # TODO: use enum instead
      argument :photoable_id, Integer, required: true
      argument :caption, String, required: false
    end
  end
end
