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

ActiveRecord::Schema[8.0].define(version: 2025_01_07_030748) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "shipment_statuses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shipments", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.string "sender_name"
    t.text "sender_address"
    t.string "receiver_name"
    t.text "receiver_address"
    t.decimal "weight"
    t.integer "boxes"
    t.bigint "truck_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "shipment_status_id", null: false
    t.index ["shipment_status_id"], name: "index_shipments_on_shipment_status_id"
    t.index ["truck_id"], name: "index_shipments_on_truck_id"
  end

  create_table "trucks", force: :cascade do |t|
    t.string "make"
    t.string "model"
    t.integer "year"
    t.integer "mileage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "shipments", "shipment_statuses"
  add_foreign_key "shipments", "trucks"
end
