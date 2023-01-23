# frozen_string_literal: true

class InventoryLevel < ApplicationRecord
  belongs_to :item
  validates :supplier, presence: true
  validates :quantity, :reorder_level, numericality: { only_integer: true }
  validates :quantity, comparison: { greater_than: :reorder_level, message: 'must be greater than reorder level' }
end
