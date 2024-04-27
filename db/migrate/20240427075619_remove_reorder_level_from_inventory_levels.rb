class RemoveReorderLevelFromInventoryLevels < ActiveRecord::Migration[7.0]
  def change
    remove_column :inventory_levels, :reorder_level, :integer
  end
end
