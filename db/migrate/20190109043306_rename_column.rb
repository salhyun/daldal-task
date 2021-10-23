class RenameColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :projects, :name, :title
    rename_column :tasks, :name, :title
  end
end
