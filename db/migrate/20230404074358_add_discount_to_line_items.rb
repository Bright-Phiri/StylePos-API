class AddDiscountToLineItems < ActiveRecord::Migration[7.0]
  def change
    add_column :line_items, :discount, :decimal
  end
end
