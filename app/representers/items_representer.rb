# frozen_string_literal: true

class ItemsRepresenter
  def initialize(items)
    @items = items
  end

  def as_json
    items.map do |item|
      {
        id: item.id,
        name: item.name,
        price: item.price,
        size: item.size,
        color: item.color,
        stock_level: stock_level(item),
        inventory_level: inventory_level(item)
      }
    end
  end

  private

  def stock_level(item)
    return 'Not added' unless item.inventory_level.present?

    if item.inventory_level.quantity <= item.inventory_level.reorder_level
      'Low stock'
    elsif item.inventory_level.quantity.zero?
      'Out of stock'
    else
      'In stock'
    end
  end

  def inventory_level(item)
    return 0 unless item.inventory_level.present?

    item.inventory_level.quantity
  end

  attr_reader :items
end
