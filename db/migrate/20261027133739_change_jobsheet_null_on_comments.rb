class ChangeJobsheetNullOnComments < ActiveRecord::Migration[7.0]
  def change
    change_column_null :comments, :jobsheet, true
  end
end
