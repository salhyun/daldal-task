class AddOrderToSections < ActiveRecord::Migration[5.2]
  def change
    add_column :sections, :order, :string
  end
end
