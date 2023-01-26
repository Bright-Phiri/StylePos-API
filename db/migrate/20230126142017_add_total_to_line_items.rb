class AddTotalToLineItems < ActiveRecord::Migration[7.0]
  def change
    add_column :line_items, :total, :decimal
  end
end
