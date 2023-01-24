# frozen_string_literal: true

class Item < ApplicationRecord
  has_one :inventory_level, dependent: :destroy
  has_many :line_items
  validates_associated :inventory_level
  validates :name, :size, :color, presence: true
  validates :price, numericality: { greater_than: 0 }
end
