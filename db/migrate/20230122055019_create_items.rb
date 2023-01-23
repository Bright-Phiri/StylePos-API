class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.string :name
      t.decimal :price
      t.string :size
      t.string :color

      t.timestamps
    end
  end
end
