module Types
  class AuthenticationInput < BaseInputObject
    argument :first_name, String, required: true
    argument :last_name, String, required: true
    argument :email, String, required: true
    argument :google_token, String, required: true
  end
end
