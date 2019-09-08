module Mutations
  class CreatePhoto < BaseMutation
    null true

    argument :photo, Types::PhotoInput, required: true

    field :photo, Types::PhotoType, null: true

    def resolve(photo:)
      boot_unauthenticated_user

      current_user = context[:current_user]
      photoable_type = photo[:photoable_type]
      photoable_id = photo[:photoable_id]

      photoable = get_photoable(current_user, photoable_type, photoable_id)

      new_photo = create_photo_resource(photoable, photo[:caption])

      { photo: new_photo }
    end

    def get_photoable(current_user, photoable_type, photoable_id)
      if photoable_type == 'User'
        photoable = User.find(photoable_id)
        # TODO: handle case of no user found with that ID
        
        boot_unauthorized_user unless photoable.id == current_user.id
      elsif photoable_type == 'Dog'
        photoable = Dog.find(photoable_id)
        # TODO: handle case of no dog found with that ID

        boot_unauthorized_user unless photoable.user.id == current_user.id
      end

      photoable
    end

    def create_photo_resource(photoable, caption)
      Photo.create!(
        photoable: photoable,
        caption: caption
      )
    end
  end
end
