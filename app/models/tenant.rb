# frozen_string_literal: true

# The Tenant model represents a distinct organization or account in the
# multitenant CRM system. All tenant-scoped data is isolated at the
# database row level using the acts_as_tenant gem.
#
# == Schema Information
#
# Table name: tenants
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  subdomain  :string           not null (unique)
#  active     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# == Indexes
#
#  index_tenants_on_subdomain  (subdomain) UNIQUE
#  index_tenants_on_active     (active)
#
class Tenant < ApplicationRecord
  # --- Associations ---
  has_many :users, dependent: :destroy
  has_many :companies, dependent: :destroy
  has_many :contacts, dependent: :destroy
  has_many :deals, dependent: :destroy
  has_many :notes, dependent: :destroy

  # --- Validations ---
  validates :name, presence: true
  validates :subdomain,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: {
              with: /\A[a-z0-9](?:[a-z0-9\-]*[a-z0-9])?\z/,
              message: "must be lowercase alphanumeric, may contain hyphens, " \
                       "and cannot start or end with a hyphen"
            },
            length: { minimum: 2, maximum: 63 }

  # --- Scopes ---
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # --- Instance Methods ---
  def deactivate!
    update!(active: false)
  end

  def activate!
    update!(active: true)
  end
end
