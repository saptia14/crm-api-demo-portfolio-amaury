# frozen_string_literal: true

class CreateContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :contacts do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email
      t.string :phone
      t.references :company, null: true, foreign_key: true
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end

    # Composite indices for tenant-scoped queries
    add_index :contacts, [:tenant_id, :email]
    add_index :contacts, [:tenant_id, :last_name]
    add_index :contacts, [:tenant_id, :company_id]
  end
end
