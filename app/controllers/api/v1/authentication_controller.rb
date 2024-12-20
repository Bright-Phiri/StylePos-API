# frozen_string_literal: true

class Api::V1::AuthenticationController < ApplicationController
  skip_before_action :authorize_request

  def login
    if Employee.exists?
      user = Employee.find_by(user_name: user_params[:user_name])
      raise ExceptionHandler::InvalidUsername unless user.present?

      authenticate_user(user)
    else
      render json: { error: 'No user account found' }, status: :not_found
    end
  end

  private

  def authenticate_user(user)
    raise ExceptionHandler::InvalidCredentials unless user.authenticate(user_params[:password])

    if user.active_status?
      token = encode_token({ user_id: user.id, exp: 24.hours.from_now.to_i })
      render json: { user:, token: }, status: :ok
    else
      render json: { message: 'User account disabled' }, status: :locked
    end
  end

  def user_params
    params.require(:user).permit(:user_name, :password)
  end
end
