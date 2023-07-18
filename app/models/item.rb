# frozen_string_literal: true

require 'barby'
require 'barby/barcode/code_128'

class Item < ApplicationRecord
  scope :best_selling, -> { joins(:line_items).group(:id).order("SUM(line_items.quantity) DESC") }
  scope :slow_moving, -> { joins(:line_items).group(:id).order("SUM(line_items.quantity) ASC") }
  scope :out_of_stock, -> { joins(:inventory_level).where('inventory_levels.quantity = ?', 0) }
  scope :in_stock, -> { joins(:inventory_level).where('inventory_levels.quantity > ?', 0) }
  scope :search, ->(query) { where("name ILIKE :query OR barcode ILIKE :query OR size ILIKE :query OR color ILIKE :query OR CAST(price AS VARCHAR) ILIKE :query", query: "%#{query}%") if query.present? }

  has_one :inventory_level, inverse_of: :item, dependent: :destroy
  has_many :line_items
  has_many :returns
  belongs_to :category, counter_cache: true
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

  def self.generate_barcode(name, color, size)
    item_name = name.split("").shuffle.join("")
    item_color = color.split("").shuffle.join("")
    gtin = item_name.byteslice(0, 4).unpack('U*').join.to_i.to_s.rjust(4, '0')
    color = item_color.byteslice(0, 2).unpack('U*').join.to_i.to_s.rjust(2, '0')
    size = size.byteslice(0, 2).unpack('U*').join.to_i.to_s.rjust(2, '0')
    data = "#{gtin}#{color}#{size}"
    barcode = Barby::Code128B.new(data)
    barcode_data = barcode.data.byteslice(1..-1)
    "#{barcode_data[0..3]}#{barcode_data[4..5]}#{barcode_data[6..7]}"
  end
end
