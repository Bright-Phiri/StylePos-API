# frozen_string_literal: true

class Config < ApplicationRecord
  VALID_VAT_RATE = [16.5, 0].freeze
  validates :vat_rate, inclusion: { in: VALID_VAT_RATE, message: ' is invalid' }
end
