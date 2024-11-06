# frozen_string_literal: true

require 'barby'
require 'barby/barcode/code_128'

class Item < ApplicationRecord
  include TaxCalculations

  scope :best_selling, -> { joins(:line_items).group(:id).order("SUM(line_items.quantity) DESC") }
  scope :slow_moving, -> { joins(:line_items).group(:id).order("SUM(line_items.quantity) ASC") }
  scope :out_of_stock, -> { joins(:inventory_level).where('inventory_levels.quantity = ?', 0) }
  scope :in_stock, -> { joins(:inventory_level).where('inventory_levels.quantity > ?', 0) }
  scope :search, ->(query) { 
    where("name ILIKE :query OR barcode ILIKE :query OR size ILIKE :query OR color ILIKE :query OR CAST(price AS VARCHAR) ILIKE :query", query: "%#{query}%") if query.present? 
  }

  belongs_to :category, counter_cache: true
  has_many :line_items, dependent: :nullify
  has_many :returns
  with_options dependent: :destroy do |assoc|
    assoc.has_many :received_items
    assoc.has_one :inventory_level, inverse_of: :item
  end

  validates_associated :line_items
  validates :name, :size, :color, presence: true
  validates :price, :selling_price, numericality: { greater_than: 0 }
  validates :reorder_level, numericality: { greater_than: 0, only_integer: true }

  after_validation :update_selling_price
  before_save :update_stock_value

  def enough_inventory?(requested_quantity)
    raise ExceptionHandler::InventoryLevelError, 'Inventory level not added' unless inventory_level.present?

    inventory_level.quantity.positive? && requested_quantity <= inventory_level.quantity
  end

  def update_stock_value
    return unless inventory_level

    inventory_level.update_attribute(:stock_value, inventory_level.quantity * selling_price)
  end

  def update_selling_price
    vat = Item.calculate_VAT(selling_price, 1)
    self.selling_price += vat
  end

  def inventory
    inventory_level&.quantity || 0
  end

  def stock_level
    return 'Not added' unless inventory_level

    if inventory_level.quantity.zero?
      'Out of stock'
    elsif inventory_level.quantity <= reorder_level
      'Low stock'
    else
      'In stock'
    end
  end

  def self.generate_barcode(item_params)
    name_code = item_params[:name].split("").shuffle.join("").byteslice(0, 4).unpack('U*').join.to_i.to_s.rjust(4, '0')
    color_code = item_params[:color].split("").shuffle.join("").byteslice(0, 2).unpack('U*').join.to_i.to_s.rjust(2, '0')
    size_code = item_params[:size].byteslice(0, 2).unpack('U*').join.to_i.to_s.rjust(2, '0')
    
    data = "#{name_code}#{color_code}#{size_code}"
    barcode = Barby::Code128B.new(data)
    barcode_data = barcode.data.byteslice(1..-1)

    "#{barcode_data[0..3]}#{barcode_data[4..5]}#{barcode_data[6..7]}"
  end
end
