class CreateEquipmentCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :equipment_categories do |t|
      t.references :school, null: false, foreign_key: { to_table: :users }
      t.string :name

      t.timestamps
    end
  end
end
