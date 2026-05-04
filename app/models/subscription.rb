# frozen_string_literal: true

class Subscription < ApplicationRecord
  acts_as_tenant :tenant

  enum :status, {
    pending: 0,
    active: 1,
    canceled: 2
  }, default: :pending

  validates :plan_name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
