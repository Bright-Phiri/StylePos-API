# frozen_string_literal: true

class Api::V1::OrdersController < ApplicationController
  def index
    orders = Order.all
    render json: orders
  end

  def add_line_item
    @line_items = []
    if @line_item.save
      @line_items << @line_item
      render json: @line_items
    else
      render json: @line_item.errors.full_messages, status: :unprocessable_entity
    end
  end

  def find_item
    @item = Item.find(params[:item_id])
    render json: @item
  end

  def set_total_price
    @line_item = @item.line_items.build(line_item_params.merge(price: @item.price))
    @line_item.total = @line_item.quantity * @line_item.price
  end

  def order_params
    params.require(:order).permit(:customer_name, line_items_attributes: [:item_id, :quantity, :price, :total])
  end

  def line_item_params
    params.require(:line_item).permit(:item_id, :quantity, :price, :total)
  end
end
