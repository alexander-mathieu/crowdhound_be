module Mutations
  class DestroyDog < BaseMutation
    null true

    argument :dog_id, ID, required: true

    field :message, String, null: true

    def resolve(dog_id:)
      boot_unauthenticated_user

      current_user = context[:current_user]

      begin
        dog = current_user.dogs.find(dog_id)
      rescue ActiveRecord::RecordNotFound
        raise GraphQL::ExecutionError, 'Unauthorized' # TODO: Replace with boot_unauthorized_user
      end

      dog.destroy

      { message: 'Dog successfully deleted' }
    end
  end
end
