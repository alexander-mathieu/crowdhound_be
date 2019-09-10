FactoryBot.define do
  factory :dog do
    user
    name { Faker::Superhero.unique.name }
    breed { Faker::Creature::Dog.breed }
    birthdate { (rand(12 * 12).months.ago).to_date }
    weight { rand(100) }
    short_desc { Faker::Hipster.sentence(word_count: 12) }
    long_desc { Faker::Hipster.paragraph(sentence_count: 8) }
    activity_level { rand(3) }
  end
end
