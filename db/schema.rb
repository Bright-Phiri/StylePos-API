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

ActiveRecord::Schema[7.0].define(version: 2023_05_05_172157) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employees", force: :cascade do |t|
    t.string "job_title"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "user_name"
    t.string "password_digest"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
  end

  create_table "inventory_levels", force: :cascade do |t|
    t.integer "quantity"
    t.integer "reorder_level"
    t.string "supplier"
    t.bigint "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_inventory_levels_on_item_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.decimal "price"
    t.string "size"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "selling_price"
    t.string "barcode"
  end

  create_table "line_items", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "order_id", null: false
    t.integer "quantity"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "total"
    t.decimal "vat"
    t.decimal "discount"
    t.index ["item_id"], name: "index_line_items_on_item_id"
    t.index ["order_id"], name: "index_line_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.decimal "total"
    t.bigint "employee_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_orders_on_employee_id"
  end

  create_table "returns", force: :cascade do |t|
    t.string "reason"
    t.decimal "refund_amount"
    t.bigint "order_id", null: false
    t.bigint "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_returns_on_item_id"
    t.index ["order_id"], name: "index_returns_on_order_id"
  end

  add_foreign_key "inventory_levels", "items"
  add_foreign_key "line_items", "items"
  add_foreign_key "line_items", "orders"
  add_foreign_key "orders", "employees"
  add_foreign_key "returns", "items"
  add_foreign_key "returns", "orders"
end
