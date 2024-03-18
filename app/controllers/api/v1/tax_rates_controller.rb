# frozen_string_literal: true

class Api::V1::TaxRatesController < ApplicationController
  before_action :set_tax_rate, only: [:update, :show, :destroy]

  def index
    render json: TaxRate.all
  end

  def show
    render json: @tax_rate
  end

  def create
    tax_rate = TaxRate.new(tax_rate_params)
    if tax_rate.save
      render json: tax_rate, status: :created
    else
      render json: tax_rate.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    if @tax_rate.update(tax_rate_params)
      render json: @tax_rate, status: :ok
    else
      render json: @tax_rate.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    @tax_rate.destroy!
    head :no_content
  end

  private

  def tax_rate_params
    params.require(:tax_rate).permit(:name, :rate)
  end

  def set_tax_rate
    @tax_rate = TaxRate.find(params[:id])
  end
end
