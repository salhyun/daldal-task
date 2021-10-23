class AddStrikeoutToChecklist < ActiveRecord::Migration[5.2]
  def change
    add_column :checklists, :strikeout, :boolean, :default => false
  end
end
