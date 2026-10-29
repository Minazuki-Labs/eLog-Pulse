class AddAssigneeToTickets < ActiveRecord::Migration[8.1]
  def change
    add_reference :tickets, :assignee, foreign_key: { to_table: :users }, null: true
  end
end
