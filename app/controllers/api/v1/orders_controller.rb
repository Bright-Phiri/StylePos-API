# frozen_string_literal: true

class Api::V1::OrdersController < ApplicationController
  before_action :set_order, only: :show
  def index
    orders = Order.preload(:employee).paginate(page: params[:page], per_page: params[:per_page])
    render json: { orders: OrdersRepresenter.new(orders).as_json, total: orders.total_entries }
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
    render json: OrderRepresenter.new(@order).as_json, status: :ok
  end

  def destroy
    Order.find(params[:id]).destroy!
    head :no_content
  end

  private

  def set_order
    @order = Order.preload(:line_items).find(params[:id])
  end
end
