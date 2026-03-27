class CreateTables < ActiveRecord::Migration[8.1]
  def change
    create_table :equipment_categories do |t|
      t.string :name

      t.timestamps
    end

    create_table :issue_types do |t|
      t.references :equipment_category, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end

    create_table :locations do |t|
      t.references :school, null: false, foreign_key: { to_table: :users }
      t.string :name

      t.timestamps
    end

    create_table :equipment do |t|
      t.references :location, null: false, foreign_key: true
      t.references :equipment_category, null: false, foreign_key: true

      t.timestamps
    end

    create_table :location_templates do |t|
      t.string :name
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.text :description

      t.timestamps
    end

    create_table :location_template_items do |t|
      t.references :location_template, null: false, foreign_key: true
      t.references :equipment_category, null: false, foreign_key: true

      t.timestamps
    end

    create_table :tickets do |t|
      t.references :school, null: false, foreign_key: { to_table: :users }
      t.references :employee, null: true, foreign_key: { to_table: :users }
      t.references :location, null: false, foreign_key: true
      t.references :equipment, null: false, foreign_key: true
      t.references :issue_type, null: false, foreign_key: true
      t.string :custom_issue_text
      t.text :description
      t.integer :status, default: 0
      t.integer :priority, default: 0
      t.datetime :assigned_at
      t.datetime :resolved_at

      t.timestamps
    end

    create_table :comments do |t|
      t.references :ticket, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end
