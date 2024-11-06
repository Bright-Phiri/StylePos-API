# frozen_string_literal: true

class Category < ApplicationRecord
  scope :get_by_name, ->(category_name) { where(name: category_name).take! }

  attr_readonly :items_count

  has_many :items, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true, allow_blank: true
end
