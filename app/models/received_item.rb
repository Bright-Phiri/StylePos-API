# frozen_string_literal: true

class ReceivedItem < ApplicationRecord
  belongs_to :item
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :batch_number, :supplier, presence: true, allow_blank: true
  validates :cost_price, :selling_price, numericality: { greater_than: 0 }
  before_save :set_stock_value, :add_to_inventory
  before_destroy :set_stock_value, :remove_from_inventory

  def set_stock_value
    self.stock_value = quantity * selling_price
  end

  def add_to_inventory
    self.item.inventory_level.update_attribute(:quantity, self.item.inventory_level.quantity + quantity)
  end

  def remove_from_inventory
    self.item.inventory_level.update_attribute(:quantity, self.item.inventory_level.quantity - quantity)
  end
end
