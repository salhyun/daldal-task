class ChangeContentFromHistory < ActiveRecord::Migration[5.2]
  def change
    change_column :histories, :content, :text
  end
end
