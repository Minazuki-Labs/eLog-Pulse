class CreateTickets < ActiveRecord::Migration[8.1]
  def change
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
  end
end
