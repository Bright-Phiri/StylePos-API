# frozen_string_literal: true

class LineItem < ApplicationRecord
  belongs_to :item
  belongs_to :order
  validates :quantity, numericality: { only_integer: true }

  after_save :update_inventory_level_and_total
  before_destroy :update_inventory_and_total

  private

  def update_inventory_level_and_total
    ActiveRecord::Base.transaction do
      self.order.update!(total: (self.order.total + self.total).round(2))
      raise ExceptionHandler::InventoryLevelError, 'Failed to update inventory and total' unless self.item.inventory_level.update_attribute(:quantity, self.item.inventory - self.quantity)
    end
  end

  def update_inventory_and_total
    ActiveRecord::Base.transaction do
      self.order.update!(total: (order.total - self.total).round(2))
      raise ExceptionHandler::InventoryLevelError, 'Failed to update inventory and total' unless self.item.inventory_level.update_attribute(:quantity, self.item.inventory + self.quantity)
    end
  end
end
