# frozen_string_literal: true

class Employee < ApplicationRecord
  enum :status, [:active, :disabled], suffix: true, default: :active

  VALID_ROLES = ['Cashier', 'Store Manager'].freeze

  has_many :orders

  has_secure_password

  validates_associated :orders
  validates :first_name, :last_name, presence: true, unless: -> { store_manager? }
  validates :password, length: { in: 6..8 }

  with_options presence: true do
    validates :user_name, uniqueness: { case_sensitive: false, conditions: -> { where(status: :active) },
                                        format: { without: /\s/, message: 'must contain no spaces' } }
    validates :job_title, inclusion: { in: VALID_ROLES }

    with_options uniqueness: { case_sensitive: false } do
      validates :phone_number, phone_number: true, allow_blank: true
      validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: 'is invalid' }
    end
  end

  with_options if: -> { store_manager? } do |manager|
    manager.validates :first_name, :last_name, presence: true, on: :update
  end

  VALID_ROLES.each do |role|
    define_method "#{role.downcase.tr(' ', '_')}?" do
      job_title == role
    end
  end

  def generate_password_token!
    self.reset_password_token = generate_token
    self.reset_password_sent_at = Time.now.utc
    save!(validate: false, touch: false)
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
