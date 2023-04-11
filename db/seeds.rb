# frozen_string_literal: true

require 'csv'

file_path = Rails.root.join('data.csv')
csv_data = File.read(file_path)
csv = CSV.parse(csv_data, headers: false)

9000.times do
  csv.each do |row|
    item = Item.new do |i|
      i.name = row[0]
      i.price = row[1]
      i.size = row[2]
      i.color = row[3]
    end
    item.save!
  end
end
