class CreateKakaoAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :kakao_accounts do |t|
      t.string :account_id
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
