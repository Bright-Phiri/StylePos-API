class RemoveNameFromEmployees < ActiveRecord::Migration[7.0]
  def change
    remove_column :employees, :name, :string
  end
end
