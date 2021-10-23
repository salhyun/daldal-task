class AddDdayToTask < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :dday, :string
  end
end
