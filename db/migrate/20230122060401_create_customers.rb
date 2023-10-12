class CreateCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :phone_number, index: { unique: true, name: 'unique_phone_numbers' }

      t.timestamps
    end
  end
end
