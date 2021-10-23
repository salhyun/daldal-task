class AddCommentCountToTask < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :comment_count, :integer, :default => 0
    add_column :tasks, :checklist_count, :integer, :default => 0
    add_column :tasks, :strikeout_count, :integer, :default => 0
  end
end
