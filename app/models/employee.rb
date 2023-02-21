# frozen_string_literal: true

class Employee < ApplicationRecord
  VALID_ROLES = ['Cashier', 'Store Manager'].freeze
  has_many :orders
  validates_associated :orders
  has_secure_password
  validates :first_name, :last_name, presence: true
  validates :password, length: { in: 6..8 }
  with_options presence: true do
    validates :user_name, uniqueness: true, format: { without: /\s/, message: 'must contain no spaces' }
    validates :job_title, inclusion: { in: VALID_ROLES }
    with_options uniqueness: { case_sensitive: false } do
      validates :phone_number, phone_number: true
      validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: 'is invalid' }
    end
  end
end
