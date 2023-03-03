# frozen_string_literal: true

class Api::V1::LineItemsController < ApplicationController
  def create
    order = Order.find(params[:order_id])
    item = Item.preload(:inventory_level).find(params[:line_item][:item_id])
    raise ExceptionHandler::InventoryLevelError, 'Not enough inventory' unless item.enough_inventory?(params[:line_item][:quantity].to_i)

    vat = LineItem.calculate_vat(item.price, params[:line_item][:quantity].to_i)
    line_item = order.line_items.create(line_item_params.merge(item_id: item.id, price: item.price + vat, vat:, total: params[:line_item][:quantity].to_i * (item.price + vat)))
    if line_item.new_record?
      render json: line_item.errors.full_messages, status: :unprocessable_entity
    else
      render json: OrderRepresenter.new(order).as_json, status: :created
    end
  end

  def destroy
    order = Order.preload(:line_items).find(params[:order_id])
    line_item = order.line_items.find(params[:id])
    line_item.destroy!
    render json: OrderRepresenter.new(order).as_json, status: :created
  end

  private

  def line_item_params
    params.require(:line_item).permit(:item_id, :quantity, :price)
  end
end
