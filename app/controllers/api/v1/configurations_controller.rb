# frozen_string_literal: true

class Api::V1::ConfigurationsController < ApplicationController
  before_action :set_configuration, only: [:update, :destroy]
  skip_before_action :require_login

  def index
    render json: Config.all
  end

  def show
    render json: @configuration
  end

  def create
    if Config.exists?
      render json: { error: 'Configuration already exists.' }, status: :conflict
    else
      configuration = Config.new(configuration_params)
      if configuration.save
        render json: configuration, status: :created
      else
        render json: configuration.errors.full_messages, status: :unprocessable_entity
      end
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
    params.require(:config).permit(:vat_rate)
  end

  def set_configuration
    @configuration = Config.find(params[:id])
  end
end
