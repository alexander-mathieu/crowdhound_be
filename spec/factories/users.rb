FactoryBot.define do
  factory :user do
    first_name { Faker::Name.unique.first_name }
    last_name { Faker::Name.unique.last_name }
    email { Faker::Internet.unique.email }
    short_desc { Faker::Hipster.sentence(word_count: 12) }
    long_desc { Faker::Hipster.paragraph(sentence_count: 8) }
  end
end
