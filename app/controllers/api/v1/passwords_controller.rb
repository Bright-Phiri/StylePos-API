# frozen_string_literal: true

class Api::V1::PasswordsController < ApplicationController
  skip_before_action :authorize_request, only: [:forgot, :reset, :change]
  before_action :set_user, only: :change

  def change
    @user.password = user_params[:password]
    @user.password_confirmation = user_params[:password_confirmation]
    if @user.save
      render json: { message: 'Password successfully updated' }, status: :ok
    else
      render json: { message: 'Failed to update password', errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def forgot_password
    user = Employee.find_by(email: user_params[:email])
    raise InvalidEmail unless user.present?

    user.generate_password_token!
    UserMailer.with(user:).password_reset.deliver_later
    render json: { message: 'A reset password link has been sent to your email' }, status: :ok
  end

  def reset_password
    user = Employee.find_by(reset_password_token: user_params[:token])
    if user.present? && user.password_token_valid?
      if user.reset_password!(user_params[:password], user_params[:password_confirmation])
        render json: { message: 'Password successfully changed' }, status: :ok
      else
        render json: { message: 'Failed to update password', errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { message: 'Token not valid or expired. Try generating a new token.' }, status: :bad_request
    end
  end

  private

  def set_user
    @user = Employee.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:user_name, :email, :password, :password_confirmation, :token)
  end
end
