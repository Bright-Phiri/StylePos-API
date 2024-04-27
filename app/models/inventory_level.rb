# frozen_string_literal: true

class InventoryLevel < ApplicationRecord
  scope :search, ->(query) { joins(:item).where("items.name ILIKE ?", "%#{query}%") if query.present? }
  belongs_to :item
  validates :supplier, presence: true, allow_blank: true
  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  after_validation :set_stock_value
  after_commit :check_inventory_level, on: [:create, :update]
  after_commit { DashboardBroadcastJob.perform_later('inventory') }

  def item_name
    item.name
  end

  def set_stock_value
    self.stock_value = quantity * item.selling_price
  end

  private

  def check_inventory_level
    ItemMailer.with(item: self.item).reorder_email.deliver_later if self.item.inventory_level.present? && self.item.inventory <= self.item.reorder_level
  end
end
