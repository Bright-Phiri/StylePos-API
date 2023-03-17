# frozen_string_literal: true

class LineItem < ApplicationRecord
  belongs_to :item
  belongs_to :order
  validates :quantity, numericality: { only_integer: true }

  after_save :update_inventory_level_and_total
  before_destroy :update_inventory_and_total

  def self.calculate_vat(pre_vat_price, requested_quantity)
    vat_rate = 16.5
    total_price = pre_vat_price * requested_quantity * (1 + (vat_rate / 100))
    vat_amount = total_price - (pre_vat_price * requested_quantity)
    formated_vat = sprintf("%20.8g", vat_amount)
    formated_vat.to_f.round(2)
  end

  private

  def update_inventory_level_and_total
    ActiveRecord::Base.transaction do
      self.order.update!(total: (self.order.total + self.total))
      raise ExceptionHandler::InventoryLevelError, 'Failed to update inventory' unless self.item.inventory_level.update_attribute(:quantity, self.item.inventory - self.quantity)
    end
  end

  def update_inventory_and_total
    ActiveRecord::Base.transaction do
      self.order.update!(total: (order.total - self.total))
      raise ExceptionHandler::InventoryLevelError, 'Failed to update inventory' unless self.item.inventory_level.update_attribute(:quantity, self.item.inventory + self.quantity)
    end
  end
end
