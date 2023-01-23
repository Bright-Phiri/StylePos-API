# frozen_string_literal: true

class LineItem < ApplicationRecord
  belongs_to :product
  belongs_to :order
end
