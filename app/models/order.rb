# frozen_string_literal: true

class Order < ApplicationRecord
  scope :of_day, ->(date) { where(created_at: date.beginning_of_day..date.end_of_day) }
  scope :statistics, -> { created_in(Date.current.year).select(:id, :created_at, 'COUNT(id)').group(:id) }
  has_many :line_items
  validates_associated :line_items
  belongs_to :employee

  after_validation :initialize_order, on: :create

  private

  def initialize_order
    self.total = 0
  end
end
