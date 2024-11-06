# frozen_string_literal: true

class InventoryLevel < ApplicationRecord
  belongs_to :item

  scope :search, ->(query) { joins(:item).where("items.name ILIKE ?", "%#{query}%") if query.present? }

  validates :supplier, presence: true, allow_blank: true
  validates :quantity, numericality: { greater_than: 0, only_integer: true }

  before_save :set_stock_value
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
    if item.inventory_level.present? && item.inventory <= item.reorder_level
      ItemMailer.with(item: item).reorder_email.deliver_later
    end
  end
end
