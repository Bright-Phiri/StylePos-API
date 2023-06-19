class AddStatusToEmployees < ActiveRecord::Migration[7.0]
  def change
    add_column :employees, :status, :integer
  end
end
