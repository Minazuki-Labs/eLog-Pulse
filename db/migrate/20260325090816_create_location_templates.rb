class CreateLocationTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :location_templates do |t|
      t.string :name
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.text :description

      t.timestamps
    end
  end
end
