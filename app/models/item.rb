# frozen_string_literal: true

class Item < ApplicationRecord
  has_one :inventory_level, dependent: :destroy
  has_many :line_items
  validates_associated :inventory_level, :line_items
  validates :name, :size, :color, presence: true
  validates :price, numericality: { greater_than: 0 }

  def enough_inventory?(requested_quantity)
    inventory_level.quantity.positive? && requested_quantity <= inventory_level.quantity
  end
end
