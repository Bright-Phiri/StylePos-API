# frozen_string_literal: true

class LineItem < ApplicationRecord
  include TaxCalculations
  default_scope { order(:created_at).reverse_order }
  belongs_to :item
  belongs_to :order
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :discount, numericality: { less_than_or_equal_to: :total, message: 'cannot be greater than total' }

  before_validation { self.discount = 0 if self.discount.nil? }

  after_commit :update_inventory_level_and_total, on: :create
  after_commit :broadcast_transaction, on: [:create, :update, :destroy]
  after_commit { DashboardBroadcastJob.perform_later('line_items') }
  before_destroy :update_inventory_and_total_on_destroy

  def self.calculate_total(selling_price, requested_quantity)
    selling_price * requested_quantity
  end

  def self.default_tax_rate
    TaxRate.last&.rate || 0.0
  end

  private

  def broadcast_transaction
    BroadcastTransactionJob.perform_later(self.order)
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
