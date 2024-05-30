# frozen_string_literal: true

class LineItemsRepresenter
  def initialize(line_items)
    @line_items = line_items
  end

  def as_json
    line_items.map do |line_item|
      {
        id: line_item.id,
        barcode: line_item.item&.barcode,
        item: line_item.item&.name,
        quantity: line_item.quantity,
        discount: line_item.discount,
        price: line_item.price,
        vat: line_item.vat,
        total: line_item.total,
        created_at: line_item.created_at
      }
    end
  end

  private

  attr_reader :line_items
end
