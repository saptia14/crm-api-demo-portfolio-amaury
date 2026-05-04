# frozen_string_literal: true

class CreateTenants < ActiveRecord::Migration[7.0]
  def change
    create_table :tenants do |t|
      t.string :name, null: false
      t.string :subdomain, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    # Unique index on subdomain for fast lookup and uniqueness enforcement
    add_index :tenants, :subdomain, unique: true

    # Index on active for filtering active tenants
    add_index :tenants, :active
  end
end
