# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :require_login
  include ExceptionHandler

  def encode_token(payload)
    payload[:exp] = 24.hours.from_now.to_i # Set expiration time to 24 hours from now
    JWT.encode(payload, Rails.application.secrets.secret_key_base)
  end

  def auth_header
    # { Authorization: 'Bearer <token>' }
    request.headers['Authorization']
  end

  def decode_action_cable_token(auth_header)
    token = auth_header.split(' ')[1]
    decode_token(token)
  end

  def decode_token(token)
    begin
      decoded = JWT.decode(token, Rails.application.secrets.secret_key_base, true, algorithm: 'HS256')
      return decoded if decoded && decoded[0]['exp'] >= Time.now.to_i
    rescue JWT::DecodeError
      nil
    end
  end

  def decoded_token
    return unless auth_header

    token = auth_header.split(' ')[1]
    decode_token(token)
  end

  def logged_in_user
    return unless decoded_token

    user_id = decoded_token[0]['user_id']
    @user = Employee.find_by(id: user_id)
  end

  def logged_in?
    !!logged_in_user
  end

  def require_login
    raise ExceptionHandler::NotAuthorized, 'Please log in' unless logged_in?
  end
end
