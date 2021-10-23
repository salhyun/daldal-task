class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :account
      t.string :password
      t.string :name
      t.string :avatar
      t.timestamps
    end
    add_index :users, [:account], unique: true #account를 유니크하게 만들어서 중복방지 한다.
  end
end
