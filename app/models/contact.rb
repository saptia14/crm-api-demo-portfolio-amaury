# frozen_string_literal: true

# Contact represents an individual person within a tenant's CRM.
# Contacts can optionally belong to a Company and have many Deals.
#
# == Schema Information
#
# Table name: contacts
#
#  id         :bigint           not null, primary key
#  first_name :string           not null
#  last_name  :string           not null
#  email      :string
#  phone      :string
#  company_id :bigint           (FK, nullable)
#  tenant_id  :bigint           not null (FK)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Contact < ApplicationRecord
  include Filterable

  # --- Multitenancy ---
  acts_as_tenant :tenant

  # --- Tagging / Segmentation ---
  acts_as_taggable_on :tags

  # --- Associations ---
  belongs_to :company, optional: true
  has_many :deals, dependent: :nullify
  has_many :notes, as: :notable, dependent: :destroy

  # --- Validations ---
  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name, presence: true, length: { maximum: 100 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP },
                    allow_blank: true

  # --- Scopes ---
  scope :alphabetical, -> { order(:last_name, :first_name) }
  scope :with_email, -> { where.not(email: [nil, ""]) }
  scope :by_company, ->(company_id) { where(company_id: company_id) if company_id.present? }

  # --- Instance Methods ---
  def full_name
    "#{first_name} #{last_name}"
  end
end
