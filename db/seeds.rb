require 'factory_bot_rails'
require 'faker'
include FactoryBot::Syntax::Methods

##### Empty database
Photo.destroy_all
Location.destroy_all
Dog.destroy_all
User.destroy_all

##### Create users
user1, user2, user3, user4, user5 = create_list(:user, 5)

##### Create dogs
dog11, dog12 = create_list(:dog, 2, user: user1)
dog21, dog22, dog23 = create_list(:dog, 3, user: user2)
dog31 = create(:dog, user: user3)
dog41 = create(:dog, user: user4)
# user5 has no dogs

#### Create photos
create_list(:photo, 3, photoable: user1)
create_list(:photo, 2, photoable: user2)

create_list(:photo, 4, photoable: dog11)
create_list(:photo, 2, photoable: dog22)

#### Create locations
create(:location, user: user1)
create(:location, user: user2)
create(:location, user: user3)
create(:location, user: user5)
# user4 has no location
