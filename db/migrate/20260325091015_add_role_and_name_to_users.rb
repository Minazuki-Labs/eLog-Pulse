class AddRoleAndNameToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :role, :integer, default: 1
    add_column :users, :name, :string
  end
end
