# frozen_string_literal: true

class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :status, null: false, default: 0
      t.date :due_date
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end

    add_index :invoices, [:tenant_id, :status]
  end
end
