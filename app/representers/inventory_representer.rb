# frozen_string_literal: true

class InventoryRepresenter
  def initialize(inventory)
    @inventory = inventory
  end

  def as_json
    {
      id: inventory.id,
      item: inventory.item_name,
      quantity: inventory.quantity,
      reorder_level: inventory.reorder_level,
      supplier: inventory.supplier
    }
  end

  private

  attr_reader :inventory
end
