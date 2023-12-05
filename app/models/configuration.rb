# frozen_string_literal: true

class Configuration < ApplicationRecord
  validates :vat_rate, presence: true, numericality: true, allow_nil: true
end
