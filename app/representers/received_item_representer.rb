# frozen_string_literal: true

class ReceivedItemRepresenter
  def initialize(received_item)
    @received_item = received_item
  end

  def as_json
    {
      id: received_item.id,
      item: received_item.item.name,
      cost_price: received_item.cost_price,
      selling_price: received_item.selling_price,
      quantity: received_item.quantity,
      batch_number: received_item.batch_number,
      stock_value: received_item.stock_value,
      supplier: received_item.supplier,
      received_on: received_item.created_at
    }
  end

  private

  attr_reader :received_item
end
