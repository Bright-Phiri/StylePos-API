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
        quantity: inventory.quantity,
        reorder_level: inventory.reorder_level,
        supplier: inventory.supplier
      }
    end
  end

  private

  attr_reader :inventories
end
