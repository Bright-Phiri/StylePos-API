# frozen_string_literal: true

class UserMailer < ApplicationMailer
  before_action :set_recepient

  def password_reset
    mail(to: email_address_with_name(@user.email, "#{@user.first_name} #{@user.last_name}"), subject: 'Reset your account password')
  end

  private

  def set_recepient
    @user = params[:user]
  end
end
