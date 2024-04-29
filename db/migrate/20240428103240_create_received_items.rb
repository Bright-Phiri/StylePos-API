class CreateReceivedItems < ActiveRecord::Migration[7.0]
  def change
    create_table :received_items do |t|
      t.belongs_to :item, null: false, foreign_key: true
      t.integer :quantity
      t.string :batch_number
      t.string :supplier
      t.decimal :cost_price
      t.decimal :selling_price
      t.decimal :stock_value

      t.timestamps
    end
  end
end
