# frozen_string_literal: true

class DashboardBroadcastJob < ApplicationJob
  queue_as :default

  def perform(type)
    data = {
      type:,
      number_of_orders: Order.of_day.count,
      total_sales: Order.sum(:total),
      daily_sales: Order.daily_revenue.sum(:total),
      weekly_revenue: Order.weekly_revenue.sum(:total),
      monthly_revenue: Order.monthly_revenue.sum(:total),
      fastest_moving_items: Item.best_selling.limit(10),
      slowest_moving_items: Item.slow_moving.limit(10),
      monthly_order_statistics: Order.statistics,
      items_out_of_stock_count: Item.out_of_stock.count,
      items_in_stock_count: Item.in_stock.count
    }
    ActionCable.server.broadcast('dashboard_channel', data)
  end
end
