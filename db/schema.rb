# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_01_183539) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "contact_submissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "inquiry_type"
    t.text "message"
    t.string "name"
    t.string "phone"
    t.boolean "responded", default: false
    t.datetime "responded_at"
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_contact_submissions_on_created_at"
    t.index ["responded"], name: "index_contact_submissions_on_responded"
  end

  create_table "leads", force: :cascade do |t|
    t.boolean "contacted", default: false
    t.datetime "contacted_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "ip_address"
    t.string "lead_type", default: "rental_inquiry"
    t.text "message"
    t.string "name", null: false
    t.string "phone"
    t.bigint "property_id", null: false
    t.string "source"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["contacted"], name: "index_leads_on_contacted"
    t.index ["created_at"], name: "index_leads_on_created_at"
    t.index ["email"], name: "index_leads_on_email"
    t.index ["property_id"], name: "index_leads_on_property_id"
  end

  create_table "properties", force: :cascade do |t|
    t.string "address", null: false
    t.boolean "auto_verified"
    t.integer "bathrooms"
    t.integer "bedrooms"
    t.string "city", null: false
    t.datetime "created_at", null: false
    t.string "data_source"
    t.string "email_1"
    t.string "email_2"
    t.string "email_3"
    t.string "email_4"
    t.string "first_name"
    t.boolean "is_verified"
    t.string "last_name"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "mailing_address"
    t.string "mailing_city"
    t.string "mailing_state"
    t.string "mailing_zip"
    t.text "meta_description"
    t.text "meta_keywords"
    t.string "person_type"
    t.string "phone_1"
    t.string "phone_2"
    t.string "phone_3"
    t.string "phone_4"
    t.string "property_id"
    t.string "property_type"
    t.string "slug", null: false
    t.string "state", default: "NJ", null: false
    t.datetime "updated_at", null: false
    t.integer "year_built"
    t.string "zip", null: false
    t.index ["city", "zip"], name: "index_properties_on_city_and_zip"
    t.index ["city"], name: "index_properties_on_city"
    t.index ["property_id"], name: "index_properties_on_property_id"
    t.index ["slug"], name: "index_properties_on_slug", unique: true
    t.index ["zip"], name: "index_properties_on_zip"
  end

  add_foreign_key "leads", "properties"
end
