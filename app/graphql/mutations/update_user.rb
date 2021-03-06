module Mutations
  class UpdateUser < BaseMutation
    null true

    argument :user, Types::Inputs::UserInput, required: false
    argument :location, Types::Inputs::LocationInput, required: false

    field :current_user, Types::CurrentUserType, null: true

    def resolve(user: nil, location: nil)
      boot_unauthenticated_user

      current_user = context[:current_user]

      if user
        user_info = user.to_hash
        current_user.update(user_info)
      end

      if location
        location_info = location.to_hash

        if current_user.location
          current_user.location.update(location_info)
        else
          current_user.create_location(location_info)
        end
      end

      { current_user: current_user }
    end
  end
end
