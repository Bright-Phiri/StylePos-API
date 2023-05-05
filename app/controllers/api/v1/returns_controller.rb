# frozen_string_literal: true

class Api::V1::ReturnsController < ApplicationController
  def index
    returns = Return.all
    render json: ReturnsRepresenter.new(returns).as_json
  end

  def return_item
    order = Order.preload(:line_items).find(params[:order_id])
    line_item = order.line_items.find(params[:line_item_id])
    item_return = line_item.item.returns.create(returns_params.merge(order_id: order.id, refund_amount: line_item.total))
    if item_return.persisted?
      line_item.destroy!
      render json: OrderRepresenter.new(order).as_json, status: :ok
    else
      render json: item_return.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def returns_params
    params.require(:return).permit(:reason)
  end
end
