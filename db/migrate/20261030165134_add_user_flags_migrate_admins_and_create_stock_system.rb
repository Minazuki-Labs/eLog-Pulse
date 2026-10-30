class AddUserFlagsMigrateAdminsAndCreateStockSystem < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :admin, :boolean, default: false, null: false
    add_column :users, :teacher, :boolean, default: false, null: false
    add_column :users, :manager, :boolean, default: false, null: false

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE users
          SET admin = TRUE, role = 1
          WHERE role = 0;
        SQL
      end

      dir.down do
        execute <<-SQL
          UPDATE users
          SET role = 0, admin = FALSE
          WHERE admin = TRUE;
        SQL
      end
    end

    create_table :stock_items do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    create_table :stock_sub_items do |t|
      t.references :stock_item, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    create_table :stock_orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :school, null: false, foreign_key: { to_table: :users }
      t.references :manager, foreign_key: { to_table: :users }

      t.references :approver_1, foreign_key: { to_table: :users }
      t.references :approver_2, foreign_key: { to_table: :users }

      t.string :company_name, null: false
      t.text :purpose
      t.integer :status, default: 0, null: false

      t.string :teacher_phone_number, null: false
      t.string :teacher_email, null: false

      t.timestamps
    end

    create_table :stock_order_items do |t|
      t.references :stock_order, null: false, foreign_key: true
      t.references :stock_sub_item, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end
  end
end
