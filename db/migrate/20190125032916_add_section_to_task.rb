class AddSectionToTask < ActiveRecord::Migration[5.2]
  def change
    add_reference :tasks, :section, foreign_key: true
  end
end
