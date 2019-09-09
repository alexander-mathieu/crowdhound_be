module Types
  class UserInput < BaseInputObject
    argument :first_name, String, required: false
    argument :last_name, String, required: false
    argument :short_desc, String, required: false
    argument :long_desc, String, required: false
  end
end
