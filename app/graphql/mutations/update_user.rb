module Mutations
  class UpdateUser < BaseMutation
    null true

    argument :user, Types::UserInput, required: false
    argument :location, Types::LocationInput, required: false

    field :current_user, Types::CurrentUserType, null: true

    def resolve(user: nil, location: nil)
      boot_unauthenticated_user

      if user
        user_info = user.to_hash
        context[:current_user].update(user_info)
      end

      if location
        location_info = location.to_hash
        context[:current_user].location.update(location_info)
      end

      { current_user: context[:current_user] }
    end
  end
end
