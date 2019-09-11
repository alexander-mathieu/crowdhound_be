module Types
  class ChatType < Types::BaseObject
    field :id, String, null: false
    field :unread_count, Int, null: true
    field :last_message_at, String, null: true
    field :user, Types::UserType, null: true

    # [
    #   {
    #     "id": "1",
    #     "created_by_id": "user2",
    #     "name": "mycoolroom",
    #     "private": false,
    #     "created_at": "2017-03-23T11:36:42Z",
    #     "updated_at": "2017-03-23T11:36:42Z",
    #     "member_user_ids":["user3", "user4"],
    #     "unread_count": 1,
    #     "last_message_at": "2017-03-23T11:36:42Z"
    #   }
    # ]
    
    def user
      current_user = context[:current_user]
      
      if current_user
        chat_member_ids = object[:member_user_ids].map(&.to_i)

        other_member_id = chat_member_ids.find do |member_id|
          current_user.id != member_id
        end

        User.find(other_member_id)
      else
        nil
      end
    end
  end
end
