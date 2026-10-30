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

ActiveRecord::Schema[8.1].define(version: 2026_10_30_165134) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "app_configs", force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_app_configs_on_key", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.integer "comment_type"
    t.datetime "created_at", null: false
    t.string "jobsheet"
    t.bigint "ticket_id", null: false
    t.json "tracked_changes"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["ticket_id"], name: "index_comments_on_ticket_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "employee_schools", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.bigint "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_employee_schools_on_employee_id"
    t.index ["school_id"], name: "index_employee_schools_on_school_id"
  end

  create_table "equipment", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "equipment_category_id", null: false
    t.bigint "location_id", null: false
    t.datetime "updated_at", null: false
    t.index ["equipment_category_id"], name: "index_equipment_on_equipment_category_id"
    t.index ["location_id"], name: "index_equipment_on_location_id"
  end

  create_table "equipment_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "issue_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "equipment_category_id", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["equipment_category_id"], name: "index_issue_types_on_equipment_category_id"
  end

  create_table "location_template_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "equipment_category_id", null: false
    t.bigint "location_template_id", null: false
    t.datetime "updated_at", null: false
    t.index ["equipment_category_id"], name: "index_location_template_items_on_equipment_category_id"
    t.index ["location_template_id"], name: "index_location_template_items_on_location_template_id"
  end

  create_table "location_templates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_location_templates_on_created_by_id"
  end

  create_table "locations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "school_id", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_locations_on_school_id"
  end

  create_table "school_emails", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.bigint "school_id", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_school_emails_on_school_id"
  end

  create_table "stock_items", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stock_order_items", force: :cascade do |t|
    t.bigint "stock_order_id", null: false
    t.bigint "stock_sub_item_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_order_id"], name: "index_stock_order_items_on_stock_order_id"
    t.index ["stock_sub_item_id"], name: "index_stock_order_items_on_stock_sub_item_id"
  end

  create_table "stock_orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "school_id", null: false
    t.bigint "manager_id"
    t.bigint "approver_1_id"
    t.bigint "approver_2_id"
    t.string "company_name", null: false
    t.text "purpose"
    t.integer "status", default: 0, null: false
    t.string "teacher_phone_number", null: false
    t.string "teacher_email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approver_1_id"], name: "index_stock_orders_on_approver_1_id"
    t.index ["approver_2_id"], name: "index_stock_orders_on_approver_2_id"
    t.index ["manager_id"], name: "index_stock_orders_on_manager_id"
    t.index ["school_id"], name: "index_stock_orders_on_school_id"
    t.index ["user_id"], name: "index_stock_orders_on_user_id"
  end

  create_table "stock_sub_items", force: :cascade do |t|
    t.bigint "stock_item_id", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_item_id"], name: "index_stock_sub_items_on_stock_item_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "equipment_id", null: false
    t.bigint "issue_type_id", null: false
    t.bigint "location_id", null: false
    t.datetime "resolved_at"
    t.bigint "school_id", null: false
    t.integer "status", default: 0
    t.string "teacher_email", null: false
    t.string "teacher_name", null: false
    t.string "teacher_phone_number", null: false
    t.datetime "updated_at", null: false
    t.bigint "assignee_id"
    t.index ["assignee_id"], name: "index_tickets_on_assignee_id"
    t.index ["equipment_id"], name: "index_tickets_on_equipment_id"
    t.index ["issue_type_id"], name: "index_tickets_on_issue_type_id"
    t.index ["location_id"], name: "index_tickets_on_location_id"
    t.index ["school_id"], name: "index_tickets_on_school_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "username", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.datetime "remember_created_at"
    t.integer "role", default: 1
    t.integer "state"
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.boolean "teacher", default: false, null: false
    t.boolean "manager", default: false, null: false
  end

  add_foreign_key "comments", "tickets"
  add_foreign_key "comments", "users"
  add_foreign_key "employee_schools", "users", column: "employee_id"
  add_foreign_key "employee_schools", "users", column: "school_id"
  add_foreign_key "equipment", "equipment_categories"
  add_foreign_key "equipment", "locations"
  add_foreign_key "issue_types", "equipment_categories"
  add_foreign_key "location_template_items", "equipment_categories"
  add_foreign_key "location_template_items", "location_templates"
  add_foreign_key "location_templates", "users", column: "created_by_id"
  add_foreign_key "locations", "users", column: "school_id"
  add_foreign_key "school_emails", "users", column: "school_id"
  add_foreign_key "stock_order_items", "stock_orders"
  add_foreign_key "stock_order_items", "stock_sub_items"
  add_foreign_key "stock_orders", "users"
  add_foreign_key "stock_orders", "users", column: "approver_1_id"
  add_foreign_key "stock_orders", "users", column: "approver_2_id"
  add_foreign_key "stock_orders", "users", column: "manager_id"
  add_foreign_key "stock_orders", "users", column: "school_id"
  add_foreign_key "stock_sub_items", "stock_items"
  add_foreign_key "tickets", "equipment"
  add_foreign_key "tickets", "issue_types"
  add_foreign_key "tickets", "locations"
  add_foreign_key "tickets", "users", column: "assignee_id"
  add_foreign_key "tickets", "users", column: "school_id"
end
