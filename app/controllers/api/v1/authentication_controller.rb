# frozen_string_literal: true

class Api::V1::AuthenticationController < ApplicationController
  skip_before_action :require_login, only: :login
  def login
    if Employee.exists?
      @user = Employee.find_by(user_name: params[:user_name])
      raise InvalidUsername, 'Username not found' unless @user.present?

      if @user&.authenticate(params[:password])
        if @user.active_status?
          token = encode_token({ user_id: @user.id, exp: 1.hour.from_now.to_i })
          render json: { user: @user, token: }, status: :ok
        else
          render json: { message: 'User account disabled' }, status: :locked
        end
      else
        render json: { error: 'Invalid username or password' }, status: :unauthorized
      end
    else
      render json: { error: 'No user account found' }, status: :not_found
    end
  end

  def auto_login
    render json: @user
  end

  private

  def user_params
    params.permit(:user_name, :email, :password)
  end
end
