# frozen_string_literal: true

class ReceivedItemsRepresenter
  def initialize(received_items)
    @received_items = received_items
  end

  def as_json
    received_items.map do |item|
      {
        id: item.id,
        item: item.item.name,
        cost_price: item.cost_price,
        selling_price: item.selling_price,
        quantity: item.quantity,
        batch_number: item.batch_number,
        stock_value: item.stock_value,
        supplier: item.supplier,
        received_on: item.created_at
      }
    end
  end

  private

  attr_reader :received_items
end
