# frozen_string_literal: true

class Api::V1::OrdersController < ApplicationController
  before_action :set_order, only: :show
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
    if @order.line_items.size.zero?
      render json: { error: 'Order summary not found' }, status: :not_found
    else
      render json: OrderRepresenter.new(@order).as_json, status: :ok
    end
  end

  def destroy
    order = Order.find(params[:id])
    order.destroy
    head :no_content
  end

  private

  def set_order
    @order = Order.preload(:line_items).find(params[:id])
  end
end
