class CreateGoogleAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :google_accounts do |t|
      t.text :id_token
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
