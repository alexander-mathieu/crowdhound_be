FactoryBot.define do
  factory :photo do
    photoable_id { nil }
    photoable_type { nil }
    source_url { "https://placedog.net/500?random" }
  end
end
