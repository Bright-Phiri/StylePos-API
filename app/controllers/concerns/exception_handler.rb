# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern
  class InvalidUsername < StandardError; end
  class InvalidEmail < StandardError; end
  class InventoryLevelError < StandardError; end

  included do
    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: "Record not found" }, status: :not_found
    end

    rescue_from ExceptionHandler::InvalidUsername do |exception|
      render json: { error: exception.message }, status: :not_found
    end

    rescue_from ExceptionHandler::InventoryLevelError do |exception|
      render json: { error: exception.message }, status: :bad_request
    end

    rescue_from ExceptionHandler::InvalidEmail do |exception|
      render json: { error: exception.message }, status: :not_found
    end

    rescue_from ActiveRecord::RecordNotSaved do |exception|
      render json: { error: exception.record.errors }, status: :unprocessable_entity
    end

    rescue_from ActiveRecord::RecordInvalid do |exception|
      render json: { error: exception.message }, status: :unprocessable_entity
    end

    rescue_from ActiveRecord::RecordNotDestroyed do |exception|
      render json: { error: exception.record.errors }, status: :unprocessable_entity
    end
  end
end
