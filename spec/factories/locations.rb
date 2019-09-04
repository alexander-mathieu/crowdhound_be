FactoryBot.define do
  factory :location do
    user
    street_address { "MyString" }
    city { "MyString" }
    state { "MyString" }
    zip_code { "MyString" }
    lat { 1.5 }
    long { 1.5 }
  end
end
