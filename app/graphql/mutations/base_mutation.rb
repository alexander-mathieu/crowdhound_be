module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    null false

    def boot_unauthenticated_user
      unless context[:current_user]
        raise GraphQL::ExecutionError, 'Unauthorized - a valid google_token query parameter is required'
      end
    end

    def boot_unauthorized_user
      raise GraphQL::ExecutionError, 'Unauthorized'
    end
  end
end
