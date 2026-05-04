# frozen_string_literal: true

# Deal represents a sales opportunity within a tenant's CRM pipeline.
# Deals progress through stages from prospect to won/lost.
#
# == Schema Information
#
# Table name: deals
#
#  id                  :bigint           not null, primary key
#  name                :string           not null
#  amount              :decimal(10,2)
#  stage               :integer          not null, default(0)
#  expected_close_date :date
#  contact_id          :bigint           (FK, nullable)
#  company_id          :bigint           (FK, nullable)
#  user_id             :bigint           not null (FK — assigned sales rep)
#  tenant_id           :bigint           not null (FK)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class Deal < ApplicationRecord
  include Filterable

  # --- Multitenancy ---
  acts_as_tenant :tenant

  # --- Tagging / Segmentation ---
  acts_as_taggable_on :tags

  # --- Associations ---
  belongs_to :contact, optional: true
  belongs_to :company, optional: true
  belongs_to :user  # assigned sales rep

  has_many :notes, as: :notable, dependent: :destroy

  # --- Enums ---
  # Pipeline stages for deal progression
  enum :stage, {
    prospect: 0,
    qualification: 1,
    proposal: 2,
    won: 3,
    lost: 4
  }, default: :prospect

  # --- Validations ---
  validates :name, presence: true, length: { maximum: 255 }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :stage, presence: true

  # --- Scopes ---
  scope :open_deals, -> { where(stage: [:prospect, :qualification, :proposal]) }
  scope :closed_deals, -> { where(stage: [:won, :lost]) }
  scope :by_stage, ->(stage) { where(stage: stage) if stage.present? }
  scope :by_user, ->(user_id) { where(user_id: user_id) if user_id.present? }
  scope :closing_soon, ->(days = 30) { where(expected_close_date: Date.current..days.days.from_now.to_date) }
  scope :high_value, ->(threshold = 10_000) { where("amount >= ?", threshold) }
  scope :by_amount_desc, -> { order(amount: :desc) }

  # --- Instance Methods ---
  def closed?
    won? || lost?
  end

  def open?
    !closed?
  end

  def total_value
    amount || 0
  end
end
