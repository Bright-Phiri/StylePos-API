# frozen_string_literal: true

class LineItem < ApplicationRecord
  belongs_to :item
  belongs_to :order
  validates :quantity, numericality: { only_integer: true }
end
