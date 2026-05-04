# frozen_string_literal: true

class Invoice < ApplicationRecord
  acts_as_tenant :tenant

  enum :status, {
    unpaid: 0,
    paid: 1,
    failed: 2
  }, default: :unpaid

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
