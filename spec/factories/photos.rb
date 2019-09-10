FactoryBot.define do
  factory :photo do
    photoable_id { nil }
    photoable_type { nil }
    sequence(:source_url) { |n| "https://placedog.net/#{n % 1000}" }
    caption { Faker::Creature::Dog.meme_phrase }
  end

  factory :user_photo, parent: :photo do
    sequence(:source_url) { |n| "https://i.pravatar.cc/300?img=#{n % 70}" }
  end
end
