class AddStockValueToInventoryLevels < ActiveRecord::Migration[7.0]
  def change
    add_column :inventory_levels, :stock_value, :decimal
  end
end
