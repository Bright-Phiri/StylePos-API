class CreateCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :phone_number, index: { unique: true }

      t.timestamps
    end
  end
end
