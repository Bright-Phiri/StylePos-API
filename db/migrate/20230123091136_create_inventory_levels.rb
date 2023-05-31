class CreateInventoryLevels < ActiveRecord::Migration[7.0]
  def change
    create_table :inventory_levels do |t|
      t.integer :quantity
      t.integer :reorder_level
      t.string :supplier
      t.belongs_to :item, index: { unique: true }, null: false, foreign_key: true

      t.timestamps
    end
  end
end
