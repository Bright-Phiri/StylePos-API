class AddReorderLevelToItems < ActiveRecord::Migration[7.0]
  def change
    add_column :items, :reorder_level, :integer
  end
end
