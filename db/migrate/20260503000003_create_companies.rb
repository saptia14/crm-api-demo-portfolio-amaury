# frozen_string_literal: true

class CreateCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :industry
      t.string :website
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end

    # Composite index for tenant-scoped queries
    add_index :companies, [:tenant_id, :name]
    add_index :companies, [:tenant_id, :industry]
  end
end
