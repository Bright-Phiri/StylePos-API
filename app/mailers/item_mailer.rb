# frozen_string_literal: true

class ItemMailer < ApplicationMailer
  def reorder_email(item)
    @item = item
    mail(to: 'inventory_manager@#.com', subject: "Reorder needed for #{item.name}")
  end
end
