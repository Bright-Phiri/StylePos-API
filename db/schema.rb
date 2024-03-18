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

ActiveRecord::Schema[7.0].define(version: 2024_03_18_094454) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "items_count"
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "configs", force: :cascade do |t|
    t.decimal "vat_rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone_number"], name: "unique_customers_phone_numbers", unique: true
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
    t.integer "status"
    t.index ["phone_number"], name: "unique_employees_phone_numbers", unique: true
  end

  create_table "inventory_levels", force: :cascade do |t|
    t.integer "quantity"
    t.integer "reorder_level"
    t.string "supplier"
    t.bigint "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_inventory_levels_on_item_id", unique: true
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
    t.bigint "category_id", null: false
    t.index ["category_id"], name: "index_items_on_category_id"
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

  create_table "tax_rates", force: :cascade do |t|
    t.string "name"
    t.decimal "rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "inventory_levels", "items"
  add_foreign_key "items", "categories"
  add_foreign_key "line_items", "items"
  add_foreign_key "line_items", "orders"
  add_foreign_key "orders", "employees"
  add_foreign_key "returns", "items"
  add_foreign_key "returns", "orders"
end
