# frozen_string_literal: true

class Order < ApplicationRecord
  scope :of_day, -> { where(created_at: Date.today.beginning_of_day..Date.today.end_of_day) }
  scope :daily_revenue, -> { where(created_at: Date.today.beginning_of_day..Date.today.end_of_day) }
  scope :statistics, -> { created_in(Date.current.year).select(:id, :created_at, 'COUNT(id)').group(:id) }
  scope :created_in, ->(year) { where('extract(year from created_at) = ?', year) if year.present? }
  has_many :line_items
  validates_associated :line_items
  belongs_to :employee

  after_validation :initialize_order, on: :create

  def processed_by
    employee.name
  end

  private

  def initialize_order
    self.total = 0
  end
end
