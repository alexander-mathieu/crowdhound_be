module Types
  class PhotoType < Types::BaseObject
    field :id, ID, null: false
    field :photoable_id, Int, null: true
    field :photoable_type, String, null: true # TODO: use enum instead
    field :source_url, String, null: true
  end
end
