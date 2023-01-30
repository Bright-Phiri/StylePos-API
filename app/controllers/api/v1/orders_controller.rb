# frozen_string_literal: true

class Api::V1::OrdersController < ApplicationController
  before_action :set_line_item, only: [:set_total_price]
  def index
    orders = Order.all
    render json: orders
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
      render json: order.line_items, status: :not_found
    else
      render json: order.line_items, status: :ok
    end
  end

  def add_line_item
    order = Order.find(params[:order_id])
    @item = Item.find(params[:line_item][:item_id])
    raise ExceptionHandler::InventoryLevelError, 'Not enough inventory' unless @item.enough_inventory?(params[:line_item][:quantity].to_i)

    @line_item = order.line_items.create(line_item_params.merge(item_id: @item.id, price: @item.price, total: params[:line_item][:quantity] * @item.price))
    if @line_item.new_record?
      render json: @line_item.errors.full_messages, status: :unprocessable_entity
    else
      ActiveRecord::Base.transaction do
        order.update!(total: (order.total + @line_item.total).round(2))
        @item.inventory_level.update!(quantity: @item.inventory - @line_item.quantity)
      end
      render json: order.line_items, status: :created
    end
  end

  def remove_line_item
    order = Order.find(params[:order_id])
    line_item = order.line_items.find(params[:id])
    ActiveRecord::Base.transaction do
      order.update!(total: (order.total - line_item.total).round(2))
      line_item.item.inventory_level.update!(quantity: line_item.item.inventory + line_item.quantity)
      line_item.destroy!
    end
    head :no_content
  end

  def set_total_price
    render json: @line_item.to_json(include: :item)
  end

  private

  def line_item_params
    params.require(:line_item).permit(:item_id, :quantity, :price)
  end

  def set_line_item
    @item = Item.find(params[:line_item][:item_id])
    @line_item = @item.line_items.build(line_item_params.merge(price: @item.price))
    @line_item.total = params[:line_item][:quantity] * @line_item.price
  end

  def set_order
    @order = Order.find(params[:id])
  end
end
