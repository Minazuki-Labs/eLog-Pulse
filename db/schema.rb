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

ActiveRecord::Schema[8.1].define(version: 2026_03_25_091015) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.bigint "ticket_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["ticket_id"], name: "index_comments_on_ticket_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
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

  create_table "tickets", force: :cascade do |t|
    t.datetime "assigned_at"
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "employee_id"
    t.bigint "equipment_id", null: false
    t.bigint "issue_type_id", null: false
    t.bigint "location_id", null: false
    t.integer "priority", default: 0
    t.datetime "resolved_at"
    t.bigint "school_id", null: false
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_tickets_on_employee_id"
    t.index ["equipment_id"], name: "index_tickets_on_equipment_id"
    t.index ["issue_type_id"], name: "index_tickets_on_issue_type_id"
    t.index ["location_id"], name: "index_tickets_on_location_id"
    t.index ["school_id"], name: "index_tickets_on_school_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 1
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "comments", "tickets"
  add_foreign_key "comments", "users"
  add_foreign_key "equipment", "equipment_categories"
  add_foreign_key "equipment", "locations"
  add_foreign_key "issue_types", "equipment_categories"
  add_foreign_key "location_template_items", "equipment_categories"
  add_foreign_key "location_template_items", "location_templates"
  add_foreign_key "location_templates", "users", column: "created_by_id"
  add_foreign_key "locations", "users", column: "school_id"
  add_foreign_key "tickets", "equipment"
  add_foreign_key "tickets", "issue_types"
  add_foreign_key "tickets", "locations"
  add_foreign_key "tickets", "users", column: "employee_id"
  add_foreign_key "tickets", "users", column: "school_id"
end
