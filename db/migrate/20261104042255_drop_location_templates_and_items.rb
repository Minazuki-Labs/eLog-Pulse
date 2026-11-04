class DropLocationTemplatesAndItems < ActiveRecord::Migration[8.1]
  def change
    # Drop dependent table first to avoid foreign key violation errors
    drop_table :location_template_items do |t|
      t.datetime "created_at", null: false
      t.bigint "equipment_category_id", null: false
      t.bigint "location_template_id", null: false
      t.datetime "updated_at", null: false
      t.index [ "equipment_category_id" ], name: "index_location_template_items_on_equipment_category_id"
      t.index [ "location_template_id" ], name: "index_location_template_items_on_location_template_id"
    end

    drop_table :location_templates do |t|
      t.datetime "created_at", null: false
      t.bigint "created_by_id", null: false
      t.text "description"
      t.string "name"
      t.datetime "updated_at", null: false
      t.index [ "created_by_id" ], name: "index_location_templates_on_created_by_id"
    end
  end
end
