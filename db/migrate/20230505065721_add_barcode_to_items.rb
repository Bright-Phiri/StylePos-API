class AddBarcodeToItems < ActiveRecord::Migration[7.0]
  def change
    add_column :items, :barcode, :string
  end
end
