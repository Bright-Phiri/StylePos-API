# frozen_string_literal: true

class ItemRepresenter
  def initialize(item)
    @item = item
  end

  def as_json
    {
      id: item.id,
      name: item.name,
      price: item.price,
      selling_price: item.selling_price,
      size: item.size,
      color: item.color,
      stock_level: item.stock_level,
      inventory_level: item.inventory
    }
  end

  private

  attr_reader :item
end
