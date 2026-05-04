# frozen_string_literal: true

# Migration to create the users table with Devise fields, tenant association,
# role enum, and JTI for JWT revocation.
#
# This migration supports Phase 2: Authentication & RBAC.

class DeviseCreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      # --- Devise: Database Authenticatable ---
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      # --- Devise: Recoverable ---
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      # --- Devise: Rememberable ---
      # t.datetime :remember_created_at

      # --- Devise: Trackable (optional, useful for CRM analytics) ---
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      # --- JWT Revocation: JTI Strategy ---
      # Each token has a unique JTI (JWT ID). When user signs out,
      # the JTI is rotated, invalidating the old token.
      t.string :jti, null: false

      # --- Multitenancy ---
      # Every user MUST belong to a tenant. Foreign key enforced at DB level.
      t.references :tenant, null: false, foreign_key: true, index: true

      # --- RBAC ---
      # Role as integer enum: admin(0), manager(1), sales_rep(2)
      # Default: sales_rep (2) — least privilege principle
      t.integer :role, null: false, default: 2

      # --- Profile Fields ---
      t.string :first_name
      t.string :last_name

      t.timestamps null: false
    end

    # Devise indices
    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true

    # JWT JTI index — must be unique for revocation to work
    add_index :users, :jti, unique: true

    # Composite index for tenant-scoped queries (tenant_id first for multitenancy)
    add_index :users, [:tenant_id, :role]
    add_index :users, [:tenant_id, :email]
  end
end
