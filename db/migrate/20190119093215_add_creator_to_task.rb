class AddCreatorToTask < ActiveRecord::Migration[5.2]
  def change
    add_reference :tasks, :creator, foreign_key: {to_table: :user}
  end
end
