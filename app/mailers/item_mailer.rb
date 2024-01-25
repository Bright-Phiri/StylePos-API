# frozen_string_literal: true

class ItemMailer < ApplicationMailer
  def reorder_email
    @item = params[:item]
    mail(to: Employee.where(job_title: 'Store Manager').pluck(:email).first, subject: "Reorder needed for #{@item.name}")
  end
end
