class CreateCompaniesAndUpdateStockOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.timestamps
    end

    remove_column :stock_orders, :company_name, :string
    add_reference :stock_orders, :company, null: true, foreign_key: true
  end
end
