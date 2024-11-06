# frozen_string_literal: true

class LineItem < ApplicationRecord
  include TaxCalculations

  default_scope { order(created_at: :desc) }

  belongs_to :item
  belongs_to :order

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :discount, numericality: { less_than_or_equal_to: :total, message: 'cannot be greater than total' }

  before_validation { self.discount ||= 0 }
  after_create_commit :update_inventory_level_and_total
  after_commit :broadcast_transaction, on: %i[create update destroy]
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
    BroadcastTransactionJob.perform_later(order)
  end

  def update_inventory_level_and_total
    ActiveRecord::Base.transaction do
      order.update!(total: order.total + total)
      new_quantity = item.inventory - quantity
      raise ExceptionHandler::InventoryLevelError, 'Failed to update inventory' unless item.inventory_level.update_attribute(:quantity, new_quantity)
    end
  end

  def update_inventory_and_total_on_destroy
    ActiveRecord::Base.transaction do
      order.update!(total: order.total - total)
      new_quantity = item.inventory + quantity
      raise ExceptionHandler::InventoryLevelError, 'Failed to update inventory' unless item.inventory_level.update_attribute(:quantity, new_quantity)
    end
  end
end
