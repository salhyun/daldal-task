class AddNotificationOrderToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :notification_order, :text
  end
end
