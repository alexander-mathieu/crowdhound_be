FactoryBot.define do
  factory :dog do
    user
    name { Faker::Superhero.unique.name }
    breed { Faker::Creature::Dog.breed }
    birthdate { Time.at(rand * Time.now.to_i).to_date }
    weight { rand(150) }
    short_desc { Faker::Movies::BackToTheFuture.quote }
    long_desc { Faker::Lorem.paragraph(sentence_count: 8) }
    activity_level { rand(2) }
  end
end
