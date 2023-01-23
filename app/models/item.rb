# frozen_string_literal: true

class Item < ApplicationRecord
  has_one :inventory_level, dependent: :destroy
end
