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

      file = context[:file]
      file_ext = file.tempfile.path.split(".")[1]
      file_name = "#{SecureRandom.hex}.#{file_ext}"

      s3.put_object(
        bucket: ENV['AWS_BUCKET'],
        key: file_name,
        body: file
      )

      new_photo = create_photo_resource(photoable, photo[:caption], file_name)

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

    def create_photo_resource(photoable, caption, file_name)
      Photo.create!(
        photoable: photoable,
        caption: caption,
        source_url: "https://#{ENV['AWS_BUCKET']}.s3.#{ENV['AWS_REGION']}.amazonaws.com/#{file_name}"
      )
    end

    def s3
      Aws::S3::Client.new(region: ENV['AWS_REGION'])
    end
  end
end
