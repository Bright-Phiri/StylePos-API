class CreateReturns < ActiveRecord::Migration[7.0]
  def change
    create_table :returns do |t|
      t.string :reason
      t.decimal :refund_amount
      t.belongs_to :order, null: false, foreign_key: true
      t.belongs_to :item, null: false, foreign_key: true

      t.timestamps
    end
  end
end
