class AddItemsCountToCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :items_count, :integer
  end
end
