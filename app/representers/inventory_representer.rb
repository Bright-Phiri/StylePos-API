# frozen_string_literal: true

class InventoryRepresenter
  def initialize(inventory)
    @inventory = inventory
  end

  def as_json
    {
      id: inventory.id,
      item: inventory.item_name,
      item_id: inventory.item_id,
      price: inventory.item.price,
      selling_price: inventory.item.selling_price,
      quantity: inventory.quantity,
      supplier: inventory.supplier
    }
  end

  private

  attr_reader :inventory
end
