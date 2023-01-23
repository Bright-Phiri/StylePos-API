# frozen_string_literal: true

class Item < ApplicationRecord
  has_one :inventory_level
end
