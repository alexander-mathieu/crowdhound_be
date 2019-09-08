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

      if photoable_type == 'User'
        photoable = User.find(photoable_id)

        boot_unauthorized_user unless photoable.id == current_user.id
      elsif photoable_type == 'Dog'
        photoable = Dog.find(photoable_id)

        boot_unauthorized_user unless photoable.user.id == current_user.id
      end

      new_photo = Photo.create!(
        photoable: photoable,
        caption: photo[:caption]
      )

      { photo: new_photo }
    end
  end
end
