# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def password_reset
    @user = params[:employee]
    mail(to: email_address_with_name(@user.email, "#{@user.first_name} #{@user.last_name}"), subject: 'Reset your account password')
  end
end
