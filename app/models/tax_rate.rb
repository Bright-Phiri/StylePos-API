# frozen_string_literal: true

class TaxRate < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :rate, numericality: true
end
