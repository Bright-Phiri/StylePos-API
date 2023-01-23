# frozen_string_literal: true

class Api::V1::CustomersController < ApplicationController
  before_action :set_customer, only: [:update, :show, :destory]
  def index
    customers = Customer.all
    render json: customers
  end

  def create
    customer = Customer.new(customer_params)
    if customer.save
      render json: customer, status: :created
    else
      render json: customer.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def customer_params
    params.require(:customer).permit(:name, :phone_number)
  end

  def set_customer
    @customer = Customer.find(params[:id])
  end
end
