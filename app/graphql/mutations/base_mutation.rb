module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    null false

    def boot_unauthenticated_user
      unless context[:current_user]
        raise GraphQL::ExecutionError, 'Unauthorized'
      end
    end
  end
end
