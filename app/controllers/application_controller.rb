# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :authorize_request
  include ExceptionHandler

  def decode_action_cable_token(auth_header)
    token = auth_header.split(' ')[1]
    decode_token(token)
  end

  protected

  def authorize_request
    if auth_header.blank?
      render_unauthorized 'Token missing'
    else
      render_unauthorized 'Invalid token format' and return unless auth_header.starts_with?('Bearer ')

      render_unauthorized 'Unauthorized: Invalid or expired token' unless logged_in?
    end
  end

  def encode_token(payload)
    JWT.encode(payload, hmac_secret)
  end

  def logged_in?
    logged_in_user.present?
  end

  def logged_in_user
    return unless decoded_token

    user_id = decoded_token[0]['user_id']
    Employee.find_by(id: user_id)
  end

  private

  def auth_header
    request.headers['Authorization']
  end

  def decode_token(token)
    JWT.decode(token, hmac_secret, true, { algorithm: 'HS256' })
  rescue JWT::DecodeError
    nil
  end

  def decoded_token
    token = auth_header.split(' ')[1]
    decode_token(token)
  end

  def render_unauthorized(message)
    render json: { status: 'login', message: }, status: :unauthorized
  end

  def hmac_secret
    Rails.application.credentials.secret_key_base
  end
end
