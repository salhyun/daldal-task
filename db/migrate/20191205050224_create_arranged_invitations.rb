class CreateArrangedInvitations < ActiveRecord::Migration[5.2]
  def change
    create_table :arranged_invitations do |t|
      t.string :account
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
