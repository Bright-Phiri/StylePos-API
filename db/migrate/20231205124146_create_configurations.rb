class CreateConfigurations < ActiveRecord::Migration[7.0]
  def change
    create_table :configurations do |t|
      t.decimal :vat_rate

      t.timestamps
    end
  end
end
