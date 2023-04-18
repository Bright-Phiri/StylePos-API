# frozen_string_literal: true

class Order < ApplicationRecord
  scope :of_day, -> { where(created_at: Date.today.beginning_of_day..Date.today.end_of_day) }
  scope :daily_revenue, -> { where(created_at: Date.today.beginning_of_day..Date.today.end_of_day) }
  scope :weekly_revenue, -> { where(created_at: Date.current.beginning_of_week..Date.current.end_of_week) }
  scope :monthly_revenue, -> { where(created_at: Date.current.beginning_of_month..Date.current.end_of_month) }
  scope :statistics, -> { created_in(Date.current.year).select(:id, :created_at, 'COUNT(id)').group(:id) }
  scope :created_in, ->(year) { where('extract(year from created_at) = ?', year) if year.present? }
  scope :search, ->(query) { joins(:employee).where("employees.first_name ILIKE :query OR employees.last_name ILIKE :query OR CAST(orders.created_at AS TEXT) ILIKE :query OR CAST(total AS VARCHAR) ILIKE :query", query: "%#{query}%") if query.present? }
  has_many :line_items, inverse_of: :order, dependent: :destroy
  belongs_to :employee

  after_validation :initialize_order, on: :create
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

  def created_at
    attributes['created_at'].strftime('%Y-%m-%d %H:%M:%S')
  end

  private

  def initialize_order
    self.total = 0
  end
end
