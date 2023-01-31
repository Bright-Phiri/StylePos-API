# frozen_string_literal: true

class ItemMailer < ApplicationMailer
  def reorder_email(item)
    @item = item
    mail(to: Employee.find_by!(job_title: 'Store Manager').pluck(:email), subject: "Reorder needed for #{item.name}")
  end
end
