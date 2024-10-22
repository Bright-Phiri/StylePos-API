class CreateTaxRates < ActiveRecord::Migration[7.0]
  def change
    create_table :tax_rates do |t|
      t.string :name, index: { unique: true }
      t.decimal :rate

      t.timestamps
    end
  end
end
