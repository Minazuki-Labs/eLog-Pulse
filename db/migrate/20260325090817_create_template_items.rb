class CreateTemplateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :template_items do |t|
      t.references :location_template, null: false, foreign_key: true
      t.references :equipment_category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
