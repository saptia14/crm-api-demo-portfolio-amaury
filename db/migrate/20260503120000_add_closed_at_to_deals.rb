# frozen_string_literal: true

class AddClosedAtToDeals < ActiveRecord::Migration[7.2]
  def change
    add_column :deals, :closed_at, :datetime
    add_index :deals, [:tenant_id, :closed_at]
    add_index :deals, [:tenant_id, :stage, :created_at]
  end
end
