class AddDetailsToEmployees < ActiveRecord::Migration[7.0]
  def change
    add_column :employees, :first_name, :string
    add_column :employees, :last_name, :string
  end
end
