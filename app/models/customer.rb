# frozen_string_literal: true

class Customer < ApplicationRecord
  has_many :orders
  validates_associated :orders
  validates :name, presence: true
  validates :phone_number, presence: true, phone_number: true
end
