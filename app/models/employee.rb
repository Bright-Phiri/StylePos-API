# frozen_string_literal: true

class Employee < ApplicationRecord
  VALID_ROLES = ['Cashier', 'Store Manager', 'SysAdmin'].freeze
  has_many :orders
  has_secure_password
  validates :name, presence: true
  validates :password, length: { in: 6..8 }
  with_options presence: true do
    validates :user_name, uniqueness: true, format: { without: /\s/, message: ' must contain no spaces' }
    validates :job_title, inclusion: { in: VALID_ROLES }
    with_options uniqueness: { case_sensitive: false } do
      validates :phone_number, format: { with: /\A(\+?(265|0){1}(1|88[0-9]|99[0-9]|98[0-9]|90[0-9]){1}[0-9]{6})\z/, message: 'is invalid' }
      validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: 'is invalid' }
    end
  end
end
