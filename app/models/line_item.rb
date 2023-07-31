# frozen_string_literal: true

class LineItem < ApplicationRecord
  default_scope { order(:created_at).reverse_order }
  VAT_RATE = 16.5
  belongs_to :item
  belongs_to :order
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :discount, numericality: { less_than_or_equal_to: :total, message: 'cannot be greater than total' }

  before_validation { self.discount = 0 if self.discount.nil? }

  after_commit :update_inventory_level_and_total, on: :create
  after_commit :broadcast_to_customer_display, on: [:create, :update, :destroy]
  after_commit { DashboardBroadcastJob.perform_later('line_items') }
  before_destroy :update_inventory_and_total_on_destroy

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

  def broadcast_to_customer_display
    TransactionBroadcastJob.perform_later(self.order)
  end

  def update_inventory_level_and_total
    ActiveRecord::Base.transaction do
      self.order.update!(total: (self.order.total + self.total))
      raise ExceptionHandler::InventoryLevelError, 'Failed to update inventory' unless self.item.inventory_level.update_attribute(:quantity, self.item.inventory - self.quantity)
    end
  end

  def update_inventory_and_total_on_destroy
    ActiveRecord::Base.transaction do
      self.order.update!(total: (order.total - self.total))
      raise ExceptionHandler::InventoryLevelError, 'Failed to update inventory' unless self.item.inventory_level.update_attribute(:quantity, self.item.inventory + self.quantity)
    end
  end
end
