class CreateHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :histories do |t|
      t.references :user, foreign_key: true
      t.references :task, foreign_key: true
      t.integer :kind
      t.integer :attr
      t.string :content
      t.integer :ref

      t.timestamps
    end
  end
end
