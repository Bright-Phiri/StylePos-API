# frozen_string_literal: true

class Api::V1::CustomersController < ApplicationController
  before_action :set_customer, only: [:update, :show, :destroy]

  def index
    customers = Customer.all
    render json: customers
  end

  def show
    render json: @customer
  end

  def create
    customer = Customer.new(customer_params)
    if customer.save
      render json: customer, status: :created
    else
      render json: customer.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    if @customer.update(customer_params)
      render json: @customer, status: :ok
    else
      render json: @customer.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    @customer.destroy!
    head :no_content
  end

  private

  def customer_params
    params.require(:customer).permit(:name, :phone_number)
  end

  def set_customer
    @customer = Customer.find(params[:id])
  end
end
