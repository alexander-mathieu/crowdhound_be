module Types
  module Inputs
    class AuthenticationInput < BaseInputObject
      argument :first_name, String, required: true
      argument :last_name, String, required: true
      argument :email, String, required: true
    end
  end
end
