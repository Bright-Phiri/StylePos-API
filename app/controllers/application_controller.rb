# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :require_login
  include ExceptionHandler

  def decode_action_cable_token(auth_header)
    token = auth_header.split(' ')[1]
    decode_token(token)
  end

  protected

  def require_login
    unless auth_header
      render json: { status: 'token missing', message: 'Authorization header is missing' }, status: :unauthorized
      return
    end
    render json: { status: 'login', message: 'Please log in' }, status: :unauthorized unless logged_in?
  end

  def encode_token(payload)
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end

  private

  def auth_header
    header = request.headers['Authorization']
    return header unless header.blank?

    nil
  end

  def logged_in?
    logged_in_user.present?
  end

  def logged_in_user
    return unless decoded_token

    user_id = decoded_token[0]['user_id']
    Employee.find_by(id: user_id)
  end

  def decoded_token
    return unless auth_header

    token = auth_header.split(' ')[1]
    decode_token(token)
  end

  def decode_token(token)
    begin
      decoded = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256')
      return decoded
    rescue JWT::DecodeError
      nil
    end
  end
end
