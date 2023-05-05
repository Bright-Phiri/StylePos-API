# frozen_string_literal: true

class OrdersRepresenter
  def initialize(orders)
    @orders = orders
  end

  def as_json
    orders.map do |order|
      {
        id: order.id,
        processed_by: order.processed_by,
        transaction_date: order.formatted_created_at,
        total: order.total,
        sub_total: order.total - order.total_vat,
        vat: order.total_vat,
        items_count: order.total_items
      }
    end
  end

  private

  attr_reader :orders
end
