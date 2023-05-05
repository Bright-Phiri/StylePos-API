# frozen_string_literal: true

class ItemsRepresenter
  def initialize(items)
    @items = items
  end

  def as_json
    items.map do |item|
      {
        id: item.id,
        barcode: item.barcode,
        name: item.name,
        price: item.price,
        selling_price: item.selling_price,
        size: item.size,
        color: item.color,
        stock_level: item.stock_level,
        inventory_level: item.inventory
      }
    end
  end

  private

  attr_reader :items
end
