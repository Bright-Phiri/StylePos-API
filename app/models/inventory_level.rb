# frozen_string_literal: true

class InventoryLevel < ApplicationRecord
  scope :search, ->(query) { joins(:item).where("items.name ILIKE ?", "%#{query}%") if query.present? }
  belongs_to :item
  validates :supplier, presence: true, allow_blank: true
  validates :quantity, :reorder_level, numericality: { greater_than: 0, only_integer: true }
  validates :quantity, comparison: { greater_than: :reorder_level, message: 'must be greater than reorder level' }, on: :create
  after_commit :check_inventory_level, on: [:create, :update]
  after_commit { DashboardBroadcastJob.perform_later('inventory') }

  def item_name
    item.name
  end

  private

  def check_inventory_level
    ItemMailer.with(item: self.item).reorder_email.deliver_later if self.item.inventory_level.present? && self.item.inventory <= self.item.inventory_level.reorder_level
  end
end
