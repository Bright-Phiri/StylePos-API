class CreateConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :configs do |t|
      t.decimal :vat_rate

      t.timestamps
    end
  end
end
