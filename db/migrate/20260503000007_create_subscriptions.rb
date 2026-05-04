# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.string :plan_name, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :status, null: false, default: 0
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end

    add_index :subscriptions, [:tenant_id, :status]
  end
end
