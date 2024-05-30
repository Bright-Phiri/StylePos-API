# frozen_string_literal: true

class LineItemRepresenter
  def initialize(line_item)
    @line_item = line_item
  end

  def as_json
    {
      id: line_item.id,
      barcode: line_item.item&.barcode || "default barcode",
      item: line_item.item&.name || "default item",
      quantity: line_item.quantity,
      discount: line_item.discount,
      price: line_item.price,
      vat: line_item.vat,
      total: line_item.total,
      created_at: line_item.created_at
    }
  end
    

  private

  attr_reader :line_item
end
