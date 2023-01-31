# frozen_string_literal: true

class Api::V1::DashboardController < ApplicationController
  def index
    # Total number of transactions processed today
    date = Date.today
    number_of_orders = Order.of_day(date).count

    # Total sales revenue
    total_sales = Order.sum(:total)

    # Best-selling items
    fastest_moving_items = Item.best_selling.limit(10)

    # slowest moving items
    slowest_moving_items = Item.slow_moving.limit(10)

    # monthly order statistics
    monthly_order_statistics = Order.statistics

    render json: { no_of_orders: number_of_orders, t_sales: total_sales, b_selling_items: fastest_moving_items, s_moving_items: slowest_moving_items, m_order_statistics: monthly_order_statistics }
  end
end
