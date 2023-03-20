# frozen_string_literal: true

class LineItem < ApplicationRecord
  belongs_to :item
  belongs_to :order
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  VAT_RATE = 16.5

  after_save :update_inventory_level_and_total
  before_destroy :update_inventory_and_total

  def self.calculate_vat(pre_vat_price, requested_quantity)
    total_price = pre_vat_price * requested_quantity * (1 + (VAT_RATE / 100))
    vat_amount = total_price - (pre_vat_price * requested_quantity)
    formated_vat = sprintf("%20.8g", vat_amount)
    formated_vat.to_f.round(2)
  end

  def self.calculate_total(pre_vat_price, requested_quantity)
    pre_vat_price * requested_quantity * (1 + (VAT_RATE / 100))
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
