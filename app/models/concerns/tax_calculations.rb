# frozen_string_literal: true

module TaxCalculations
  extend ActiveSupport::Concern

  included do
    def self.calculate_VAT(selling_price, requested_quantity)
      tax_rate = TaxRate.last&.rate || 0.0
      total_price = selling_price * requested_quantity * (tax_rate.to_f / 100 + 1)
      vat_amount = total_price - (selling_price * requested_quantity)
      formatted_vat = sprintf("%20.8g", vat_amount)
      formatted_vat.to_f.round(2)
    end

    def self.calculate_vat_fraction(selling_price, quantity)
      tax_rate = TaxRate.last&.rate || 0.0
      total_price = selling_price * quantity
      vat_amount = (total_price * tax_rate) / (100 + tax_rate)
      vat_amount.round(2)
    end
  end
end
