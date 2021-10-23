class CreateWorkers < ActiveRecord::Migration[5.2]
  def change
    create_table :workers do |t|
      t.references :task, foreign_key: true
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
