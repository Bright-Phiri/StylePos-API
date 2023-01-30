# frozen_string_literal: true

class Customer < ApplicationRecord
  validates_associated :orders
  validates :name, presence: true
  validates :phone_number, presence: true, phone_number: true
end
