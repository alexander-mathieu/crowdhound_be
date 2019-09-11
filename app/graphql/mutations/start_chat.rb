module Mutations
  class StartChat < BaseMutation
    null true

    argument :user_id, String, required: true

    field :message, String, null: true

    def resolve(user_id:)
      boot_unauthenticated_user

      user = User.find_by(id: user_id)
      unless user boot_unauthorized_user

      participant_ids = [context[:current_user].id, user_id]

      room_id = "#{participant_ids.min}-#{participant_ids.min}"

      ChatkitService.connect.get_room({
        id: room_id
      })

      # ChatkitService.connect.create_room({
      #   id: room_id
      #   creator_id: context[:current_user].id.to_s,
      #   name: room_id,
      #   user_ids: participant_ids.map(&:to_s),
      #   private: true
      # })

      { message: "success" }
    end
  end
end
