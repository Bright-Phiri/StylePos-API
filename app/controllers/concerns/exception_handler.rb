# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern

  class NotAuthorized < StandardError; end
  class InventoryLevelError < StandardError; end

  class UnauthorizedAction < StandardError
    def initialize(msg = 'Sorry, you are not authorized to perform this action.')
      super
    end
  end

  class InvalidEmail < StandardError
    def initialize(msg = 'Email address not found')
      super
    end
  end

  class InvalidCredentials < StandardError
    def initialize(msg = 'Invalid username or password')
      super
    end
  end

  class InvalidUsername < StandardError
    def initialize(msg = 'Username not found')
      super
    end
  end

  included do
    rescue_from ExceptionHandler::NotAuthorized do |exception|
      render_error(exception.message, :unauthorized)
    end

    rescue_from ExceptionHandler::UnauthorizedAction do |exception|
      render json: { message: exception.message }, status: :unauthorized
    end

    rescue_from ExceptionHandler::InvalidCredentials, ExceptionHandler::InventoryLevelError do |exception|
      render_error(exception.message, :bad_request)
    end

    rescue_from ExceptionHandler::InvalidUsername, ExceptionHandler::InvalidEmail, ActiveRecord::RecordNotFound do |exception|
      render_error(exception.message || 'Record not found', :not_found)
    end

    rescue_from ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid, ActiveRecord::RecordNotDestroyed do |exception|
      render json: { error: exception.record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def render_error(message, status)
    render json: { error: message }, status:
  end
end
