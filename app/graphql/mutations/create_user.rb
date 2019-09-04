module Mutations
  class CreateUser < BaseMutation
    # define return fields
    type Types::UserType

    # define arguments
    argument :first_name, String, required: true
    argument :last_name, String, required: true
    argument :email, String, required: true
    argument :short_desc, String, required: false
    argument :long_desc, String, required: false

    # define resolve method
    def resolve(first_name:, last_name:, email:, short_desc: nil, long_desc: nil)
      User.create!(
        first_name: first_name,
        last_name:  last_name,
        email:      email,
        short_desc: short_desc,
        long_desc:  long_desc
      )
    end
  end
end
