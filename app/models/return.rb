# frozen_string_literal: true

class Return < ApplicationRecord
  include CreatedAtFormatting

  belongs_to :order
  belongs_to :item

  validates :reason, presence: true
  validates :refund_amount, numericality: { greater_than: 0 }
end
