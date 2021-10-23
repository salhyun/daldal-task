class AddColorToSections < ActiveRecord::Migration[5.2]
  def change
    add_column :sections, :color, :string
  end
end
