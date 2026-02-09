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

ActiveRecord::Schema[8.1].define(version: 2026_02_09_180000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "contact_submissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "inquiry_type"
    t.text "message"
    t.string "name"
    t.string "phone"
    t.decimal "recaptcha_score"
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
    t.decimal "recaptcha_score"
    t.string "source"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["contacted"], name: "index_leads_on_contacted"
    t.index ["created_at"], name: "index_leads_on_created_at"
    t.index ["email"], name: "index_leads_on_email"
    t.index ["property_id"], name: "index_leads_on_property_id"
  end

  create_table "ownership_claims", force: :cascade do |t|
    t.text "admin_notes"
    t.datetime "created_at", null: false
    t.bigint "property_id", null: false
    t.datetime "reviewed_at"
    t.string "reviewed_by"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.text "verification_notes", null: false
    t.index ["property_id"], name: "index_ownership_claims_on_property_id"
    t.index ["status"], name: "index_ownership_claims_on_status"
    t.index ["user_id", "property_id"], name: "index_ownership_claims_on_user_id_and_property_id", unique: true
    t.index ["user_id"], name: "index_ownership_claims_on_user_id"
  end

  create_table "properties", force: :cascade do |t|
    t.string "address", null: false
    t.jsonb "amenities", default: []
    t.boolean "auto_verified"
    t.jsonb "availability", default: []
    t.integer "bathrooms"
    t.integer "bedrooms"
    t.string "broker_email"
    t.string "broker_name"
    t.string "broker_phone"
    t.string "broker_website"
    t.string "city", null: false
    t.datetime "created_at", null: false
    t.string "data_source"
    t.text "description"
    t.string "email_1"
    t.string "email_2"
    t.string "email_3"
    t.string "email_4"
    t.text "fee_descriptions"
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
    t.integer "occupancy_limit"
    t.jsonb "owner_amenities", default: []
    t.boolean "owner_customized", default: false
    t.text "owner_description"
    t.integer "owner_minimum_nights", default: 7
    t.decimal "owner_nightly_rate", precision: 10, scale: 2
    t.boolean "owner_pet_friendly"
    t.string "owner_rental_type", default: "weekly"
    t.text "owner_special_notes"
    t.jsonb "owner_weekly_calendar", default: {}
    t.decimal "owner_weekly_rate", precision: 10, scale: 2
    t.string "person_type"
    t.string "phone_1"
    t.string "phone_2"
    t.string "phone_3"
    t.string "phone_4"
    t.jsonb "photo_order", default: []
    t.jsonb "photos", default: []
    t.string "property_id"
    t.string "property_name"
    t.string "property_type"
    t.text "rate_description"
    t.jsonb "rates", default: []
    t.integer "rtr_property_id"
    t.integer "rtr_reference_id"
    t.datetime "rtr_synced_at"
    t.string "slug", null: false
    t.boolean "smoking"
    t.string "state", default: "NJ", null: false
    t.integer "total_sleeps"
    t.datetime "updated_at", null: false
    t.string "virtual_tour_url"
    t.integer "year_built"
    t.string "zip", null: false
    t.index ["city", "zip"], name: "index_properties_on_city_and_zip"
    t.index ["city"], name: "index_properties_on_city"
    t.index ["property_id"], name: "index_properties_on_property_id"
    t.index ["rtr_reference_id"], name: "index_properties_on_rtr_reference_id", unique: true, where: "(rtr_reference_id IS NOT NULL)"
    t.index ["slug"], name: "index_properties_on_slug", unique: true
    t.index ["zip"], name: "index_properties_on_zip"
  end

  create_table "property_analytics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.integer "page_views", default: 0
    t.bigint "property_id", null: false
    t.integer "search_impressions", default: 0
    t.integer "unique_visitors", default: 0
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_property_analytics_on_date"
    t.index ["property_id", "date"], name: "index_property_analytics_on_property_id_and_date", unique: true
    t.index ["property_id"], name: "index_property_analytics_on_property_id"
  end

  create_table "property_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_type", null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}
    t.bigint "property_id", null: false
    t.string "referrer"
    t.string "session_id"
    t.string "user_agent"
    t.index ["created_at"], name: "index_property_events_on_created_at"
    t.index ["property_id", "event_type", "created_at"], name: "idx_on_property_id_event_type_created_at_9e17ad42e0"
    t.index ["property_id"], name: "index_property_events_on_property_id"
  end

  create_table "property_submissions", force: :cascade do |t|
    t.integer "bathrooms"
    t.integer "bedrooms"
    t.string "city"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.text "message"
    t.string "owner_name", null: false
    t.string "phone"
    t.string "property_address", null: false
    t.float "recaptcha_score"
    t.boolean "reviewed", default: false
    t.datetime "reviewed_at"
    t.string "state"
    t.datetime "updated_at", null: false
    t.string "zip"
    t.index ["created_at"], name: "index_property_submissions_on_created_at"
    t.index ["email"], name: "index_property_submissions_on_email"
    t.index ["reviewed"], name: "index_property_submissions_on_reviewed"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "email_verification_token"
    t.boolean "email_verified", default: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "password_digest", null: false
    t.string "phone"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "leads", "properties"
  add_foreign_key "ownership_claims", "properties"
  add_foreign_key "ownership_claims", "users"
  add_foreign_key "property_analytics", "properties"
  add_foreign_key "property_events", "properties"
end
