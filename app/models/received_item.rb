# frozen_string_literal: true

class ReceivedItem < ApplicationRecord
  include CreatedAtFormatting
  scope :search, ->(query) { where("batch_number ILIKE :query OR supplier ILIKE :query OR CAST(price AS VARCHAR) ILIKE :query", query: "%#{query}%") if query.present? }
  belongs_to :item
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :batch_number, :supplier, presence: true, allow_blank: true
  validates :cost_price, :selling_price, numericality: { greater_than: 0 }
  before_save :check_inventory, :set_stock_value, :add_to_inventory, :update_prices
  before_destroy :set_stock_value, :remove_from_inventory

  def check_inventory
    raise ExceptionHandler::InventoryLevelError, 'Inventory level not added for this item' unless item.inventory_level.present?
  end

  def set_stock_value
    self.stock_value = quantity * selling_price
  end

  def add_to_inventory
    self.item.inventory_level.update_attribute(:quantity, self.item.inventory_level.quantity + quantity)
  end

  def update_prices
    self.item.update_columns(price: cost_price, selling_price:)
  end

  def remove_from_inventory
    self.item.inventory_level.update_attribute(:quantity, self.item.inventory_level.quantity - quantity)
  end
end
