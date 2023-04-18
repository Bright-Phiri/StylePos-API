class AddSellingPriceToItems < ActiveRecord::Migration[7.0]
  def change
    add_column :items, :selling_price, :decimal
  end
end
