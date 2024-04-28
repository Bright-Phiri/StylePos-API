# frozen_string_literal: true

class ReceivedItem < ApplicationRecord
  belongs_to :item
  validates :received_quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :batch_number, :supplier, presence: true, allow_blank: true
  validates :cost_price, :selling_price, numericality: true
  before_save :set_stock_value

  def set_stock_value
    self.stock_value = quantity * selling_price
  end
end
