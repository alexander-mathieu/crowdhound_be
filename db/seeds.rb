require 'factory_bot_rails'
require 'faker'
include FactoryBot::Syntax::Methods

##### Empty database
Photo.destroy_all
Location.destroy_all
Dog.destroy_all
User.destroy_all

##### Create users
user1, user2, user3, user4, user5, user6, user7, user8, user9, user10 = create_list(:user, 10)
dogless_user1, dogless_user2, dogless_user3 = create_list(:user, 3)

##### Create dogs
dog11, dog12, dog13 = create_list(:dog, 3, user: user1)
dog21, dog22, dog23 = create_list(:dog, 3, user: user2)
dog31, dog32, dog33 = create_list(:dog, 3, user: user3)
dog41, dog42, dog43 = create_list(:dog, 3, user: user4)
dog51, dog52, dog53 = create_list(:dog, 3, user: user5)
dog61, dog62, dog63 = create_list(:dog, 3, user: user6)
dog71, dog72, dog73 = create_list(:dog, 3, user: user7)
dog81, dog82, dog83 = create_list(:dog, 3, user: user8)
dog91, dog92, dog93 = create_list(:dog, 3, user: user9)
dog101, dog102, dog103 = create_list(:dog, 3, user: user10)

#### Create photos - users
create_list(:user_photo, 3, photoable: user1)
create_list(:user_photo, 3, photoable: user2)
create_list(:user_photo, 2, photoable: user3)
create_list(:user_photo, 2, photoable: user4)
# user5 has no photos
create_list(:user_photo, 2, photoable: user6)
create_list(:user_photo, 2, photoable: user7)
# user8 has no photos
create_list(:user_photo, 2, photoable: user9)
# user10 has no photos
create_list(:user_photo, 1, photoable: dogless_user1)
create_list(:user_photo, 1, photoable: dogless_user2)
create_list(:user_photo, 1, photoable: dogless_user3)

#### Create photos - dogs
create_list(:photo, 3, photoable: dog11)
create_list(:photo, 2, photoable: dog12)
create_list(:photo, 2, photoable: dog13)
create_list(:photo, 3, photoable: dog21)
create_list(:photo, 2, photoable: dog22)
create_list(:photo, 2, photoable: dog23)
create_list(:photo, 3, photoable: dog31)
create_list(:photo, 2, photoable: dog32)
create_list(:photo, 2, photoable: dog33)
# dog41 has no photos
create_list(:photo, 2, photoable: dog42)
create_list(:photo, 2, photoable: dog43)
create_list(:photo, 3, photoable: dog51)
# dog52 has no photos
create_list(:photo, 2, photoable: dog53)
create_list(:photo, 3, photoable: dog61)
create_list(:photo, 2, photoable: dog62)
# dog63 has no photos
create_list(:photo, 3, photoable: dog71)
create_list(:photo, 2, photoable: dog72)
create_list(:photo, 2, photoable: dog73)
create_list(:photo, 3, photoable: dog81)
# dog82 has no photos
create_list(:photo, 2, photoable: dog83)
create_list(:photo, 3, photoable: dog91)
create_list(:photo, 2, photoable: dog92)
create_list(:photo, 2, photoable: dog93)
create_list(:photo, 3, photoable: dog101)
create_list(:photo, 2, photoable: dog102)
create_list(:photo, 2, photoable: dog103)

#### Create locations
Location.create!(
  user: user1,
  street_address: '1331 17th Street',
  city: 'Denver',
  state: 'CO',
  zip_code: '80202'
)
Location.create!(
  user: user2,
  street_address: '494 East 19th Avenue',
  city: 'Denver',
  state: 'CO',
  zip_code: '80203'
)
Location.create!(
  user: user3,
  street_address: '15330 East 120th Place',
  city: 'Commerce City',
  state: 'CO',
  zip_code: '80022'
)
# user4 has no location
Location.create!(
  user: user5,
  street_address: '2001 Colorado Boulevard',
  city: 'Denver',
  state: 'CO',
  zip_code: '80205'
)
Location.create!(
  user: user6,
  street_address: '6000 Victory Way',
  city: 'Commerce City',
  state: 'CO',
  zip_code: '80022'
)
Location.create!(
  user: user7,
  street_address: '1701 Bryant Street',
  city: 'Denver',
  state: 'CO',
  zip_code: '80204'
)
Location.create!(
  user: user8,
  street_address: '8500 Peña Boulevard',
  city: 'Denver',
  state: 'CO',
  zip_code: '80249'
)
Location.create!(
  user: user9,
  street_address: '2323 South Havana Street',
  city: 'Aurora',
  state: 'CO',
  zip_code: '80014'
)
Location.create!(
  user: user10,
  street_address: '2950 South Broadway',
  city: 'Englewood',
  state: 'CO',
  zip_code: '80113'
)
Location.create!(
  user: dogless_user1,
  street_address: '11450 Broomfield Lane',
  city: 'Broomfield',
  state: 'CO',
  zip_code: '80021'
)
# dogless_user2 has no location
# dogless_user3 has no location
