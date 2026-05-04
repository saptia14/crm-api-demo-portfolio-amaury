# frozen_string_literal: true

class CreateNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :notes do |t|
      t.text :body, null: false
      t.references :notable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end

    # Composite indices for tenant-scoped polymorphic queries
    add_index :notes, [:tenant_id, :notable_type, :notable_id]
    add_index :notes, [:tenant_id, :user_id]
  end
end
