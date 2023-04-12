# frozen_string_literal: true

class InventoryLevel < ApplicationRecord
  belongs_to :item
  validates :supplier, presence: true, allow_blank: true
  validates :quantity, :reorder_level, numericality: { greater_than: 0, only_integer: true }
  validates :quantity, comparison: { greater_than: :reorder_level, message: 'must be greater than reorder level' }, on: :create
  after_save :check_inventory_level

  def item_name
    item.name
  end

  private

  def check_inventory_level
    ItemMailer.reorder_email(self.item).deliver_later if self.item.inventory_level.present? && self.item.inventory <= self.item.inventory_level.reorder_level
  end
end
