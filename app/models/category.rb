# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :items, dependent: :destroy
  validates :name, presence: true
  validates :description, presence: true, allow_blank: true
  attr_readonly :items_count
end
