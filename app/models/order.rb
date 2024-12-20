# frozen_string_literal: true

class Order < ApplicationRecord
  include CreatedAtFormatting

  default_scope { order(created_at: :desc) }
  scope :of_day, -> { where(created_at: Date.current.all_day) }
  scope :daily_revenue, -> { where(created_at: Date.current.all_day) }
  scope :weekly_revenue, -> { where(created_at: Date.current.beginning_of_week(:sunday)..Date.current.end_of_week(:sunday)) }
  scope :monthly_revenue, -> { where(created_at: Date.current.beginning_of_month..Date.current.end_of_day) }
  scope :statistics, -> { created_in(Date.current.year).select(:id, :created_at, 'COUNT(id)').group(:id) }
  scope :created_in, ->(year) { where('extract(year from created_at) = ?', year) if year.present? }
  scope :search, ->(query) {
    joins(:employee).where(
      "employees.first_name ILIKE :query OR employees.last_name ILIKE :query OR CAST(orders.created_at AS TEXT) ILIKE :query OR CAST(total AS VARCHAR) ILIKE :query",
      query: "%#{query}%"
    ) if query.present?
  }

  belongs_to :employee
  has_many :line_items, inverse_of: :order, dependent: :destroy
  has_many :returns

  after_validation :initialize_order, on: :create
  after_create_commit { BroadcastTransactionJob.perform_later(self) }
  after_commit { DashboardBroadcastJob.perform_later('order') }

  def processed_by
    "#{employee.first_name} #{employee.last_name}"
  end

  def total_vat
    line_items.sum(:vat)
  end

  def total_discount
    line_items.sum(:discount)
  end

  def total_items
    line_items.sum(:quantity)
  end

  private

  def initialize_order
    self.total = 0
  end
end
