module Mutations
  class StartChat < BaseMutation
    null true

    argument :user_id, Int, required: true

    field :room_id, String, null: true

    def resolve(user_id:)
      boot_unauthenticated_user

      user = User.find_by(id: user_id)
      boot_unauthorized_user unless user

      [context[:current_user], user].each do |db_user|
        chatkit_service.find_or_create_chatkit_user(db_user)
      end

      room = chatkit_service.find_or_create_room(user_id)

      { room_id: room[:body][:id] }
    end

    def chatkit_service
      chatkit_service ||= ChatkitService.new(context[:current_user])
    end
  end
end
