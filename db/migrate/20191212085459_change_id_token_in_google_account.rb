class ChangeIdTokenInGoogleAccount < ActiveRecord::Migration[5.2]
  def change
    rename_column :google_accounts, :id_token, :sub
  end
end
