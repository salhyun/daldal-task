class AddSecureCodeToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :secure_code, :string
  end
end
