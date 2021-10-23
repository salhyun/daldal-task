class CreateAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :attachments do |t|
      t.references :user, foreign_key: true
      t.references :task, foreign_key: true
      t.string :kind
      t.string :name
      t.string :original
      t.string :thumb
      t.timestamps
    end
  end
end
