# frozen_string_literal: true

class Api::V1::LineItemsController < ApplicationController
  before_action :set_line_item, only: [:set_total_price]

  def create
    order = Order.find(params[:order_id])
    item = Item.preload(:inventory_level).find(params[:line_item][:item_id])
    raise ExceptionHandler::InventoryLevelError, 'Not enough inventory' unless item.enough_inventory?(params[:line_item][:quantity].to_i)

    line_item = order.line_items.create(line_item_params.merge(item_id: item.id, price: item.price, total: params[:line_item][:quantity] * item.price))
    if line_item.new_record?
      render json: line_item.errors.full_messages, status: :unprocessable_entity
    else
      render json: { order_total: order.total, line_items: LineItemsRepresenter.new(order.line_items).as_json }, status: :created
    end
  end

  def destroy
    order = Order.preload(:line_items).find(params[:order_id])
    line_item = order.line_items.find(params[:id])
    line_item.destroy!
    render json: { order_total: order.total, line_items: LineItemsRepresenter.new(order.line_items.reload).as_json }, status: :ok
  end

  def set_total_price
    render json: LineItemRepresenter.new(@line_item).as_json
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
end
