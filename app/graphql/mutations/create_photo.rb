require 'base64'

module Mutations
  class CreatePhoto < BaseMutation
    null true

    argument :photo, Types::Inputs::PhotoInput, required: true

    field :photo, Types::PhotoType, null: true

    def resolve(photo:)
      boot_unauthenticated_user

      current_user = context[:current_user]
      photoable_type = photo[:photoable_type]
      photoable_id = photo[:photoable_id]

      photoable = get_photoable(current_user, photoable_type, photoable_id)

      raw_file = context[:file]

      if !raw_file
        raise GraphQL::ExecutionError, 'Image must be provided as a "file" query parameter'
      end

      meta, encoded_file = raw_file.split(',')

      before_semicolon = meta.split(';')[0]
      file_ext = before_semicolon.split('/')[1]
      file_name = "#{SecureRandom.hex}.#{file_ext}"

      decoded_file = Base64.decode64(encoded_file)

      raise_error_if_not_image_file(file_ext)

      s3.put_object(
        bucket: ENV['AWS_BUCKET'],
        key: file_name,
        body: decoded_file
      )

      new_photo = create_photo_resource(photoable, photo[:caption], file_name)

      { photo: new_photo }
    end

    private

    def get_photoable(current_user, photoable_type, photoable_id)
      begin
        if photoable_type == 'User'
          photoable = User.find(photoable_id)

          boot_unauthorized_user unless photoable.id == current_user.id
        elsif photoable_type == 'Dog'
          photoable = Dog.find(photoable_id)

          boot_unauthorized_user unless photoable.user.id == current_user.id
        end
      rescue ActiveRecord::RecordNotFound
        boot_unauthorized_user
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

    def raise_error_if_not_image_file(file_ext)
      if !file_ext_whitelist.include?(file_ext)
        raise GraphQL::ExecutionError, "File must be of one of the following types: #{file_ext_whitelist.join(', ')}"
      end
    end

    def file_ext_whitelist
      ['bmp', 'jpeg', 'jpg', 'tiff', 'png']
    end
  end
end
