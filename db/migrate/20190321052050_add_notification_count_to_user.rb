class AddNotificationCountToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :notification_count, :integer, :default => 0
  end
end
