class CreateRoletypes < ActiveRecord::Migration[5.2]
  def change
    create_table :roletypes do |t|
      t.string :name
      t.string :name_kr
      t.string :desc

      t.timestamps
    end
  end
end
