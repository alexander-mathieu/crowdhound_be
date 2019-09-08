module Mutations
  class CreateLocation < BaseMutation
    null true

    argument :location, Types::LocationInput, required: true

    field :location, Types::LocationType, null: true

    def resolve(location:)
      boot_unauthenticated_user

      begin
        location = Location.create(
          user: context[:current_user],
          street_address: location[:street_address],
          city: location[:city],
          state: location[:state],
          zip_code: location[:zip_code]
        )
      rescue RuntimeError => e
        raise GraphQL::ExecutionError, e.message
      end

      { location: location }
    end
  end
end
