class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :name, index: { unique: true }
      t.text :description

      t.timestamps
    end
  end
end
