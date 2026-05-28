class AddSystemLogFieldsToComments < ActiveRecord::Migration[8.1]
  def change
    add_column :comments, :comment_type, :integer
    add_column :comments, :tracked_changes, :json
  end
end
