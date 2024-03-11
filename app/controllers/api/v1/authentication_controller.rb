# frozen_string_literal: true

class Api::V1::AuthenticationController < ApplicationController
  skip_before_action :require_login, only: :login
  def login
    if Employee.exists?
      @user = Employee.find_by(user_name: params[:user_name])
      raise ExceptionHandler::InvalidUsername, 'Username not found' unless @user.present?

      authenticate_user(@user)
    else
      render json: { error: 'No user account found' }, status: :not_found
    end
  end

  private

  def authenticate_user(user)
    raise ExceptionHandler::InvalidCredentials, 'Invalid username or password' unless user.authenticate(params[:password])

    if user.active_status?
      token = encode_token({ user_id: user.id, exp: 1.hour.from_now.to_i })
      render json: { user: user, token: token }, status: :ok
    else
      render json: { message: 'User account disabled' }, status: :locked
    end
  end

  def user_params
    params.permit(:user_name, :email, :password)
  end
end
