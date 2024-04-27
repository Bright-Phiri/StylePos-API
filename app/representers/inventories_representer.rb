# frozen_string_literal: true

class InventoriesRepresenter
  def initialize(inventories)
    @inventories = inventories
  end

  def as_json
    inventories.map do |inventory|
      {
        id: inventory.id,
        item: inventory.item_name,
        item_id: inventory.item_id,
        price: inventory.item.price,
        selling_price: inventory.item.selling_price,
        quantity: inventory.quantity,
        stock_value: inventory.stock_value,
        supplier: inventory.supplier
      }
    end
  end

  private

  attr_reader :inventories
end
