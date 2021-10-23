class CreateInvitations < ActiveRecord::Migration[5.2]
  def change
    create_table :invitations do |t|
      t.references :requestor, foreign_key: { to_table: :users}
      t.references :accepter, foreign_key: { to_table: :users}
      t.boolean :agreed, null: false, default: false

      t.timestamps
    end
  end
end
