# frozen_string_literal: true

class Configuration < ApplicationRecord
  VALID_VAT_RATE = [16.5].freeze
  validates :vat_rate, inclusion: { in: VALID_VAT_RATE, message: 'must be 16.5' }, allow_nil: true
end
