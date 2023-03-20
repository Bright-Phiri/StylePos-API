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

  def generate_password_token!
    self.reset_password_token = generate_token
    self.reset_password_sent_at = Time.now.utc
    save!(validate: false)
  end

  def password_token_valid?
    (reset_password_sent_at + 2.hours) > Time.now.utc
  end

  def reset_password!(password, password_confirmation)
    self.reset_password_token = nil
    self.password = password
    self.password_confirmation = password_confirmation
    save!
  end

  private

  def generate_token
    SecureRandom.hex(10)
  end
end
