require 'factory_bot'
include FactoryBot::Syntax::Methods

##### Empty database
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
