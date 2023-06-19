# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name(Rails.application.credentials.sys_email, 'StylePos Notifications')
  layout "mailer"
end
