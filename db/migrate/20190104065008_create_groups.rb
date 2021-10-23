class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.references :creator, foreign_key: { to_table: :users}
      t.string :name
      t.text :desc

      t.timestamps
    end
  end
end
