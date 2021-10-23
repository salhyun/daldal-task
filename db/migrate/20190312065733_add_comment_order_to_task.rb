class AddCommentOrderToTask < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :comment_order, :text
  end
end
