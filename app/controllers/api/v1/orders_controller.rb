# frozen_string_literal: true

class Api::V1::OrdersController < ApplicationController
  def index
    orders = Order.all
    render json: orders
  end
end
