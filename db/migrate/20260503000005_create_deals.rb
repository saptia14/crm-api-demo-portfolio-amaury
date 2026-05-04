# frozen_string_literal: true

class CreateDeals < ActiveRecord::Migration[7.0]
  def change
    create_table :deals do |t|
      t.string :name, null: false
      t.decimal :amount, precision: 10, scale: 2
      t.integer :stage, null: false, default: 0
      t.date :expected_close_date
      t.references :contact, null: true, foreign_key: true
      t.references :company, null: true, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end

    # Composite indices for tenant-scoped queries
    add_index :deals, [:tenant_id, :stage]
    add_index :deals, [:tenant_id, :user_id]
    add_index :deals, [:tenant_id, :company_id]
    add_index :deals, [:tenant_id, :expected_close_date]
  end
end
