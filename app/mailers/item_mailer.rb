# frozen_string_literal: true

class ItemMailer < ApplicationMailer
  before_action :set_reorder_item
  def reorder_email
    mail(to: Employee.where(job_title: 'Store Manager').pluck(:email).first, subject: "Reorder needed for #{@item.name}")
  end

  private

  def set_reorder_item
    @item = params[:item]
  end
end
