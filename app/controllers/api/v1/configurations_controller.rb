# frozen_string_literal: true

class Api::V1::ConfigurationsController < ApplicationController
  before_action :set_category, only: [:show, :update, :destroy]

  def show
    render json: @configuration
  end

  def create
    configuration = Configuration.new(configuration_params)
    if configuration.save
      render json: configuration, status: :created
    else
      render json: configuration.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    if @configuration.update(configuration_params)
      render json: @configuration, status: :ok
    else
      render json: @configuration.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    @configuration.destroy!
    head :no_content
  end

  private

  def configuration_params
    params.require(:configuration).permit(:vat_rate)
  end

  def set_category
    @configuration = Configuration.find(params[:id])
  end
end
