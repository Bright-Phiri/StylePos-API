# frozen_string_literal: true

class Api::V1::LineItemsController < ApplicationController
  before_action :set_line_item, only: [:update, :destroy, :apply_discount]
  def create
    order = Order.find(params[:order_id])
    item = Item.preload(:inventory_level).find(line_item_params[:item_id])
    create_or_update_line_item(order, item)
  end

  def update
    @line_item.destroy! unless line_item_params[:quantity].to_i <= 0
    create_or_update_line_item(@line_item.order, @line_item.item)
  end

  def destroy
    @line_item.destroy!
    render json: OrderRepresenter.new(@order).as_json, status: :ok
  end

  def apply_discount
    if @line_item.update(discount: line_item_params[:discount].to_f, total: @line_item.total - line_item_params[:discount].to_f)
      @line_item.order.update(total: (@line_item.order.total - @line_item.discount))
      render json: OrderRepresenter.new(@order).as_json, status: :ok
    else
      render json: @line_item.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def line_item_params
    params.require(:line_item).permit(:item_id, :order_id, :quantity, :discount)
  end

  def set_line_item
    @line_item = LineItem.find(params[:id])
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
