# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_09_06_225333) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dogs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.string "breed"
    t.date "birthdate"
    t.integer "weight"
    t.text "short_desc"
    t.text "long_desc"
    t.integer "activity_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_level"], name: "index_dogs_on_activity_level"
    t.index ["birthdate"], name: "index_dogs_on_birthdate"
    t.index ["breed"], name: "index_dogs_on_breed"
    t.index ["user_id"], name: "index_dogs_on_user_id"
    t.index ["weight"], name: "index_dogs_on_weight"
  end

  create_table "locations", force: :cascade do |t|
    t.bigint "user_id"
    t.string "street_address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.float "lat"
    t.float "long"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lat"], name: "index_locations_on_lat"
    t.index ["long"], name: "index_locations_on_long"
    t.index ["user_id"], name: "index_locations_on_user_id"
  end

  create_table "photos", force: :cascade do |t|
    t.string "photoable_type"
    t.bigint "photoable_id"
    t.string "source_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["photoable_id", "photoable_type"], name: "index_photos_on_photoable_id_and_photoable_type"
    t.index ["photoable_type", "photoable_id"], name: "index_photos_on_photoable_type_and_photoable_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.text "short_desc"
    t.text "long_desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "google_token"
    t.index ["google_token"], name: "index_users_on_google_token"
  end

  add_foreign_key "dogs", "users"
  add_foreign_key "locations", "users"
end
