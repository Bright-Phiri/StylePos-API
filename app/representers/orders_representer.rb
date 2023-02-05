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
        transaction_date: order.created_at,
        total: order.total
      }
    end
  end

  private

  attr_reader :orders
end
