# frozen_string_literal: true

class Order < ApplicationRecord
  has_many :line_items
  validates_associated :line_items
  accepts_nested_attributes_for :line_items, allow_destroy: true
  belongs_to :customer
  belongs_to :employee
end
