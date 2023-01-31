# frozen_string_literal: true

class Item < ApplicationRecord
  scope :best_selling, -> { joins(:line_items).group(:id).order("SUM(line_items.quantity) DESC") }
  scope :slow_moving, -> { joins(:line_items).group(:id).order("SUM(line_items.quantity) ASC") }
  has_one :inventory_level, dependent: :destroy
  has_many :line_items
  validates_associated :inventory_level, :line_items
  validates :name, :size, :color, presence: true
  validates :price, numericality: { greater_than: 0 }

  def enough_inventory?(requested_quantity)
    inventory_level.quantity.positive? && requested_quantity <= inventory_level.quantity
  end

  def inventory
    return 0 unless inventory_level.present?

    inventory_level.quantity
  end

  def stock_level
    return 'Not added' unless inventory_level.present?

    if inventory_level.quantity <= inventory_level.reorder_level
      'Low stock'
    elsif inventory_level.quantity.zero?
      'Out of stock'
    else
      'In stock'
    end
  end
end
