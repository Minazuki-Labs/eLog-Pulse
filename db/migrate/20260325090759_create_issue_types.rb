class CreateIssueTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :issue_types do |t|
      t.references :equipment_category, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
