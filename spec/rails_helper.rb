require('simplecov')
SimpleCov.start

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

VCR.configure do |config|
  config.ignore_hosts "#{ENV['AWS_BUCKET']}.s3.#{ENV['AWS_REGION']}.amazonaws.com", "us1.pusherplatform.io"
  config.ignore_localhost = true
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.filter_sensitive_data('<GOOGLE_MAPS_API_KEY>') { ENV['GOOGLE_MAPS_API_KEY'] }
  config.filter_sensitive_data('<AWS_ACCESS_KEY_ID>') { ENV['AWS_ACCESS_KEY_ID'] }
  config.filter_sensitive_data('<AWS_SECRET_ACCESS_KEY>') { ENV['AWS_SECRET_ACCESS_KEY'] }
  config.filter_sensitive_data('<CHATKIT_INSTANCE_LOCATOR>') { ENV['CHATKIT_INSTANCE_LOCATOR'] }
  config.filter_sensitive_data('<CHATKIT_SECRET_KEY>') { ENV['CHATKIT_SECRET_KEY'] }
  config.default_cassette_options = { record: :new_episodes }
end

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.include FactoryBot::Syntax::Methods
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

#### helper methods for testing GraphQL responses
## DogType
def dog_type_attributes
  '
  id
  name
  age
  breed
  weight
  birthdate
  activityLevel
  shortDesc
  longDesc
  distance
  '
end

def compare_gql_and_db_dogs(graphql_dog, db_dog, include_id = true)
  if include_id
    expect(graphql_dog).to include(
      id:          db_dog.id.to_s
    )
  end

  expect(graphql_dog).to include(
    name:          db_dog.name,
    breed:         db_dog.breed,
    weight:        db_dog.weight,
    birthdate:     db_dog.birthdate.to_s,
    activityLevel: db_dog.activity_level,
    shortDesc:     db_dog.short_desc,
    longDesc:      db_dog.long_desc
  )

  expect(graphql_dog[:age]).to be_within(0.001).of(db_dog.age)
end

## UserType
def user_type_attributes
  '
  id
  firstName
  shortDesc
  longDesc
  distance
  '
end

def compare_gql_and_db_users(graphql_user, db_user)
    expect(graphql_user).to include(
    id:        db_user.id.to_s,
    firstName: db_user.first_name,
    shortDesc: db_user.short_desc,
    longDesc:  db_user.long_desc
  )
end

## CurrentUserType
def current_user_type_attributes
  user_type_attributes + '
  lastName
  email
  '
end

def compare_gql_and_db_current_users(graphql_user, db_user)
    expect(graphql_user).to include(
    id:        db_user.id.to_s,
    firstName: db_user.first_name,
    lastName:  db_user.last_name,
    email:     db_user.email,
    shortDesc: db_user.short_desc,
    longDesc:  db_user.long_desc
  )
end

## PhotoType
def photo_type_attributes
  '
  id
  photoableId
  photoableType
  caption
  sourceUrl
  '
end

def compare_gql_and_db_photos(graphql_photo, db_photo, include_id_and_source_url = true)
  if include_id_and_source_url
    expect(graphql_photo).to include(
      id:          db_photo.id.to_s,
      sourceUrl:   db_photo.source_url
    )
  end

  expect(graphql_photo).to include(
    photoableId:   db_photo.photoable.id,
    photoableType: db_photo.photoable.class.to_s,
    caption:       db_photo.caption
  )
end

## LocationType
def location_type_attributes
  '
  id
  streetAddress
  city
  state
  zipCode
  lat
  long
  '
end

def compare_gql_and_db_locations(graphql_location, db_location)
  expect(graphql_location).to include(
    id:            db_location.id.to_s,
    streetAddress: db_location.street_address,
    city:          db_location.city,
    state:         db_location.state,
    zipCode:       db_location.zip_code,
  )

  expect(graphql_location[:lat]).to be_within(0.001).of(db_location.lat)
  expect(graphql_location[:long]).to be_within(0.001).of(db_location.long)
end
