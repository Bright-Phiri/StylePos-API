class AddPasswordDigestToEmployees < ActiveRecord::Migration[7.0]
  def change
    add_column :employees, :password_digest, :string
  end
end
