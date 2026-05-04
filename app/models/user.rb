# frozen_string_literal: true

# The User model represents an authenticated user within a tenant.
# Users are scoped to tenants via acts_as_tenant and authenticated
# via Devise with JWT tokens using the JTI revocation strategy.
#
# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           not null, default("")
#  encrypted_password     :string           not null, default("")
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  jti                    :string           not null (unique)
#  tenant_id              :bigint           not null (FK)
#  role                   :integer          not null, default(2)
#  first_name             :string
#  last_name              :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# == Indexes
#
#  index_users_on_email                (email) UNIQUE
#  index_users_on_jti                  (jti) UNIQUE
#  index_users_on_reset_password_token (reset_password_token) UNIQUE
#  index_users_on_tenant_id            (tenant_id)
#  index_users_on_tenant_id_and_email  (tenant_id, email)
#  index_users_on_tenant_id_and_role   (tenant_id, role)
#
class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # --- Devise Modules ---
  # :database_authenticatable — email/password authentication
  # :registerable             — allow sign-up via API
  # :recoverable              — password reset via token
  # :validatable              — email/password format validations
  # :trackable                — sign-in count, timestamps, IP tracking
  # :jwt_authenticatable      — stateless JWT token authentication
  devise :database_authenticatable, :registerable, :recoverable,
         :validatable, :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # --- Multitenancy ---
  # Every user belongs to exactly one tenant.
  # acts_as_tenant automatically adds belongs_to :tenant
  # and scopes all queries to the current tenant.
  acts_as_tenant :tenant

  # --- RBAC ---
  # Roles are stored as integers for performance.
  # Default: sales_rep (least privilege principle).
  enum :role, {
    admin: 0,
    manager: 1,
    sales_rep: 2,
    super_admin: 3
  }, default: :sales_rep

  # --- Validations ---
  validates :role, presence: true
  validates :first_name, length: { maximum: 100 }, allow_blank: true
  validates :last_name, length: { maximum: 100 }, allow_blank: true

  # --- Callbacks ---
  # Generate a unique JTI before creation if not already set.
  # The JTI is rotated on sign-out to revoke the old token.
  before_create :set_jti

  # --- Associations ---
  # Explicitly declare belongs_to for clarity (acts_as_tenant adds this,
  # but we want it visible in the model for documentation purposes).
  # Note: acts_as_tenant already handles this, so we comment it to avoid duplication.
  # belongs_to :tenant

  # Phase 3 associations
  has_many :deals, dependent: :nullify
  has_many :notes, dependent: :nullify

  # --- Instance Methods ---

  def full_name
    [first_name, last_name].compact_blank.join(" ").presence || email
  end

  def super_admin?
    role == "super_admin"
  end

  def admin?
    role == "admin"
  end

  def manager?
    role == "manager"
  end

  def sales_rep?
    role == "sales_rep"
  end

  # Override Devise JWT payload to include role and tenant info
  def jwt_payload
    super.merge(
      "role" => role,
      "tenant_id" => tenant_id
    )
  end

  private

  def set_jti
    self.jti ||= SecureRandom.uuid
  end
end
