class AddHistoryCountToTask < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :history_count, :integer, :default => 0
  end
end
