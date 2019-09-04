FactoryBot.define do
  factory :location do
    street_address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip_code { Faker::Address.zip }
    lat { Faker::Address.latitude }
    long { Faker::Address.longitude }
  end
end
