# frozen_string_literal: true

# Company represents a business entity within a tenant's CRM.
# Companies can have many contacts and deals associated with them.
#
# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  industry   :string
#  website    :string
#  tenant_id  :bigint           not null (FK)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Company < ApplicationRecord
  # --- Multitenancy ---
  acts_as_tenant :tenant

  # --- Associations ---
  has_many :contacts, dependent: :nullify
  has_many :deals, dependent: :nullify
  has_many :notes, as: :notable, dependent: :destroy

  # --- Validations ---
  validates :name, presence: true, length: { maximum: 255 }
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
                                message: "must be a valid URL" },
                      allow_blank: true

  # --- Scopes ---
  scope :by_industry, ->(industry) { where(industry: industry) if industry.present? }
  scope :alphabetical, -> { order(:name) }
end
