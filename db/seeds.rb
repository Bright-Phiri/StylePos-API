# frozen_string_literal: true

# require 'csv'

# file_path = Rails.root.join('data.csv')
# csv_data = File.read(file_path)
# csv = CSV.parse(csv_data, headers: false)
# 20.times do
#   csv.each do |row|
#     item = Item.new do |i|
#       i.name = row[0]
#       i.price = row[1]
#       i.size = row[2]
#       i.color = row[3]
#     end
#     item.save!
#   end
# end

# 1.times do
#   items = Item.find_each(batch_size: 50) do |item|
#     inventory_level = item.create_inventory_level(quantity: 10, reorder_level: 3, supplier: 'Test')
#     if inventory_level.new_record?
# #       puts inventory_level.errors.full_messages
# #     end
# #   end
# end

categories_array = ["Electronics", "Books", "Home Appliances", "Beauty and Personal Care", "Toys and Games", "Automotive", "Art and Craft Supplies", "Sports and Fitness"]
categories_array.each do |category|
  Category.create(name: category, desription: category)
end
