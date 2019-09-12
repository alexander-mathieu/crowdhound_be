module Types
  class ChatType < Types::BaseObject
    field :id, String, null: false
    field :unread_count, Int, null: true
    field :last_message_at, String, null: true
    field :user, Types::UserType, null: true

    def user
      current_user = context[:current_user]
      
      if current_user
        chat_member_ids = object[:member_user_ids].map(&:to_i)

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
