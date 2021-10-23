class AddChecklistOrderToTask < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :checklist_order, :string
  end
end
