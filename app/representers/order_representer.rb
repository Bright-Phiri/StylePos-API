# frozen_string_literal: true

class OrderRepresenter
  def initialize(order)
    @order = order
  end

  def as_json
    {
      id: order.id,
      processed_by: order.processed_by,
      transaction_date: order.formatted_created_at,
      total: order.total,
      sub_total: order.total - order.total_vat,
      vat: order.total_vat,
      discount: order.total_discount,
      items_count: order.total_items,
      line_items: LineItemsRepresenter.new(order.line_items.reload).as_json
    }
  end

  private

  attr_reader :order
end
