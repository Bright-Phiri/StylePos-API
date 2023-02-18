# frozen_string_literal: true

class Api::V1::OrdersController < ApplicationController
  before_action :set_line_item, only: [:set_total_price]
  def index
    orders = Order.preload(:employee).all
    render json: OrdersRepresenter.new(orders).as_json
  end

  def create
    employee = Employee.find(params[:employee_id])
    order = employee.orders.create
    if order.persisted?
      render json: order, status: :created
    else
      render json: order.errors.full_messages, status: :unprocessable_entity
    end
  end

  def show
    order = Order.find(params[:id])
    if order.line_items.size.zero?
      render json: { error: 'Order summary not found' }, status: :not_found
    else
      render json: LineItemsRepresenter.new(order.line_items).as_json, status: :ok
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end
end
