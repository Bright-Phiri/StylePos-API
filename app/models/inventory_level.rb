# frozen_string_literal: true

class InventoryLevel < ApplicationRecord
  belongs_to :item
end
