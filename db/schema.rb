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

ActiveRecord::Schema[8.0].define(version: 2025_06_01_211809) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_number"
  end

  create_table "deliveries", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "truck_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.index ["status"], name: "index_deliveries_on_status"
    t.index ["truck_id"], name: "index_deliveries_on_truck_id"
    t.index ["user_id"], name: "index_deliveries_on_user_id"
  end

  create_table "delivery_shipments", force: :cascade do |t|
    t.bigint "delivery_id"
    t.bigint "shipment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "sender_address"
    t.text "receiver_address"
    t.float "sender_latitude"
    t.float "sender_longitude"
    t.float "receiver_latitude"
    t.float "receiver_longitude"
    t.datetime "loaded_date"
    t.datetime "delivered_date"
    t.index ["delivery_id"], name: "index_delivery_shipments_on_delivery_id"
    t.index ["shipment_id"], name: "index_delivery_shipments_on_shipment_id"
  end

  create_table "forms", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "company_id", null: false
    t.string "title", null: false
    t.string "form_type", null: false
    t.jsonb "content", default: {}, null: false
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "formable_type"
    t.bigint "formable_id"
    t.index ["company_id"], name: "index_forms_on_company_id"
    t.index ["formable_type", "formable_id"], name: "index_forms_on_formable"
    t.index ["user_id"], name: "index_forms_on_user_id"
  end

  create_table "shipment_action_preferences", force: :cascade do |t|
    t.string "action"
    t.bigint "company_id", null: false
    t.bigint "shipment_status_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_shipment_action_preferences_on_company_id"
    t.index ["shipment_status_id"], name: "index_shipment_action_preferences_on_shipment_status_id"
  end

  create_table "shipment_statuses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id", null: false
    t.boolean "locked_for_customers", default: false, null: false
    t.boolean "closed", default: false, null: false
    t.index ["company_id"], name: "index_shipment_statuses_on_company_id"
  end

  create_table "shipments", force: :cascade do |t|
    t.string "name"
    t.string "sender_name"
    t.text "sender_address"
    t.string "receiver_name"
    t.text "receiver_address"
    t.decimal "weight"
    t.bigint "truck_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "shipment_status_id"
    t.bigint "user_id"
    t.bigint "company_id"
    t.decimal "length"
    t.decimal "width"
    t.decimal "height"
    t.float "sender_latitude"
    t.float "sender_longitude"
    t.float "receiver_latitude"
    t.float "receiver_longitude"
    t.index ["company_id"], name: "index_shipments_on_company_id"
    t.index ["shipment_status_id"], name: "index_shipments_on_shipment_status_id"
    t.index ["truck_id"], name: "index_shipments_on_truck_id"
    t.index ["user_id"], name: "index_shipments_on_user_id"
  end

  create_table "trucks", force: :cascade do |t|
    t.string "make"
    t.string "model"
    t.integer "year"
    t.integer "mileage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id", null: false
    t.decimal "length"
    t.decimal "width"
    t.decimal "height"
    t.decimal "weight"
    t.string "vin", null: false
    t.string "license_plate", null: false
    t.boolean "active", default: false
    t.index ["company_id"], name: "index_trucks_on_company_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "drivers_license"
    t.bigint "company_id"
    t.string "home_address"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "deliveries", "trucks"
  add_foreign_key "deliveries", "users"
  add_foreign_key "delivery_shipments", "deliveries"
  add_foreign_key "delivery_shipments", "shipments"
  add_foreign_key "forms", "companies"
  add_foreign_key "forms", "users"
  add_foreign_key "shipment_action_preferences", "companies"
  add_foreign_key "shipment_action_preferences", "shipment_statuses"
  add_foreign_key "shipment_statuses", "companies"
  add_foreign_key "shipments", "companies"
  add_foreign_key "shipments", "shipment_statuses"
  add_foreign_key "shipments", "trucks"
  add_foreign_key "shipments", "users"
  add_foreign_key "trucks", "companies"
  add_foreign_key "users", "companies"
end
