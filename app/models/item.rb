# frozen_string_literal: true

class Item < ApplicationRecord
  scope :best_selling, -> { joins(:line_items).group(:id).order("SUM(line_items.quantity) DESC") }
  scope :slow_moving, -> { joins(:line_items).group(:id).order("SUM(line_items.quantity) ASC") }
  scope :out_of_stock, -> { joins(:inventory_level).where('inventory_levels.quantity = ?', 0) }
  scope :in_stock, -> { joins(:inventory_level).where('inventory_levels.quantity > ?', 0) }
  has_one :inventory_level, inverse_of: :item, dependent: :destroy
  has_many :line_items
  validates_associated :line_items
  validates :name, :size, :color, presence: true
  validates :price, numericality: { greater_than: 0 }

  def enough_inventory?(requested_quantity)
    raise ExceptionHandler::InventoryLevelError, 'Inventory level not added' unless inventory_level.present?

    inventory_level.quantity.positive? && requested_quantity <= inventory_level.quantity
  end

  def inventory
    return 0 unless inventory_level.present?

    inventory_level.quantity
  end

  def stock_level
    return 'Not added' unless inventory_level.present?

    if inventory_level.quantity <= inventory_level.reorder_level && inventory_level.quantity != 0
      'Low stock'
    elsif inventory_level.quantity.zero?
      'Out of stock'
    else
      'In stock'
    end
  end
end
