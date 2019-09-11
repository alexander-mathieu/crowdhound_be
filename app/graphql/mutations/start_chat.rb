module Mutations
  class StartChat < BaseMutation
    null true

    argument :user_id, Int, required: true

    field :room_id, String, null: true

    def resolve(user_id:)
      boot_unauthenticated_user

      current_user = context[:current_user]

      user = User.find_by(id: user_id)
      boot_unauthorized_user unless user

      [current_user, user].each do |db_user|
        chatkit_service.find_or_create_chatkit_user(db_user)
      end

      participant_ids = [current_user.id, user_id]

      room_id = "#{participant_ids.min}-#{participant_ids.max}"

      begin
        ChatkitService.connect.get_room({
          id: room_id
        })
      rescue => err
        if err.error_description == 'The requested room does not exist'
          ChatkitService.connect.create_room({
            id: room_id,
            creator_id: current_user.id.to_s,
            name: room_id,
            user_ids: participant_ids.map(&:to_s),
            private: true
          })
        else
          raise GraphQL::ExecutionError, err.message
        end
      end

      { room_id: room_id }
    end

    def chatkit_service
      chatkit_service ||= ChatkitService.new(context[:current_user])
    end
  end
end
