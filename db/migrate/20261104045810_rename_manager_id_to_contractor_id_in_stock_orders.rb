class RenameManagerIdToContractorIdInStockOrders < ActiveRecord::Migration[8.1]
  def change
    rename_column :stock_orders, :manager_id, :contractor_id
  end
end
