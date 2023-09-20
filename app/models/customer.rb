# frozen_string_literal: true

class Customer < ApplicationRecord
  validates :name, presence: true
  validates :phone_number, presence: true, phone_number: true
end
