# frozen_string_literal: true

class Customer < ApplicationRecord
  has_many :orders
  validates_associated :orders
  validates :name, presence: true
  validates :phone_number, presence: true, format: { with: /\A(\+?(265|0){1}(1|88[0-9]|99[0-9]|98[0-9]|90[0-9]){1}[0-9]{6})\z/, message: 'is invalid' }
end
