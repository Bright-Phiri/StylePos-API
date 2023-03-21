# frozen_string_literal: true

class Api::V1::LineItemsController < ApplicationController
  before_action :set_line_item, only: [:update, :destroy]
  def create
    order = Order.find(params[:order_id])
    item = Item.preload(:inventory_level).find(params[:line_item][:item_id])
    create_or_update_line_item(order, item)
  end

  def update
    @line_item.destroy! unless params[:line_item][:quantity].to_i <= 0
    create_or_update_line_item(@line_item.order, @line_item.item)
  end

  def destroy
    @line_item.destroy!
    render json: OrderRepresenter.new(@order).as_json, status: :ok
  end

  private

  def line_item_params
    params.require(:line_item).permit(:item_id, :order_id, :quantity, :price)
  end

  def set_line_item
    @order = Order.preload(:line_items).find(params[:order_id])
    @line_item = @order.line_items.find(params[:id])
  end

  def create_or_update_line_item(order, item)
    raise ExceptionHandler::InventoryLevelError, 'Not enough inventory' unless item.enough_inventory?(params[:line_item][:quantity].to_i)

    vat = LineItem.calculate_vat(item.price, params[:line_item][:quantity].to_i)
    line_item = order.line_items.create(line_item_params.merge(item_id: item.id, price: item.price + vat, vat:, total: LineItem.calculate_total(item.price, params[:line_item][:quantity].to_i)))
    if line_item.new_record?
      render json: line_item.errors.full_messages, status: :unprocessable_entity
    else
      render json: OrderRepresenter.new(order).as_json, status: :ok
    end
  end
end
