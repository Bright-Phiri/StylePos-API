# frozen_string_literal: true

require 'csv'

category = Category.first
file_path = Rails.root.join('data.csv')
csv_data = File.read(file_path)
csv = CSV.parse(csv_data, headers: false)
csv.each do |row|
  item = category.items.create(
    name: row[0], price: row[1], size: row[2], color: row[3],
    barcode: Item.generate_barcode(row[0], row[3], row[2]),
    selling_price: row[1].to_f + LineItem.calculate_vat(row[1].to_f, 1))
end
