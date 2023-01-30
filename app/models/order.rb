# frozen_string_literal: true

class Order < ApplicationRecord
  has_many :line_items
  validates_associated :line_items
  belongs_to :employee

  after_validation :initialize_order, on: :create

  private

  def initialize_order
    self.total = 0
  end
end
