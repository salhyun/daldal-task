class AddPlayerToNotification < ActiveRecord::Migration[5.2]
  def change
    add_reference :notifications, :player, foreign_key: {to_table: :user}
  end
end
