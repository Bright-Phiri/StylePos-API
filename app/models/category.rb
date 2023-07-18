# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :items, dependent: :destory
  validates :name, :description, presence: true
  attr_readonly :items_count
end
