class AddVatToLineItems < ActiveRecord::Migration[7.0]
  def change
    add_column :line_items, :vat, :decimal
  end
end
