# frozen_string_literal: true

require 'csv'

category = Category.create(name: 'Clothing', description: 'A variety of stylish clothing for every occasion, from casual to formal')
file_path = Rails.root.join('data.csv')
csv_data = File.read(file_path)
csv = CSV.parse(csv_data, headers: false)
csv.each do |row|
  item = Item.new do |i|
    i.name = row[0]
    i.price = row[1]
    i.size = row[2]
    i.color = row[3]
    i.category_id = category.id
  end
  item.save!
end
