class ChangeIdTokenToBeStringInGoogleAccount < ActiveRecord::Migration[5.2]
  def change
    change_column :google_accounts, :id_token, :string
  end
end
