# frozen_string_literal: true

# Note represents a free-text annotation attached to any notable record
# (Contact, Deal, or Company) via polymorphic association.
#
# == Schema Information
#
# Table name: notes
#
#  id           :bigint           not null, primary key
#  body         :text             not null
#  notable_type :string           not null (polymorphic)
#  notable_id   :bigint           not null (polymorphic)
#  user_id      :bigint           not null (FK — author)
#  tenant_id    :bigint           not null (FK)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Note < ApplicationRecord
  # --- Multitenancy ---
  acts_as_tenant :tenant

  # --- Associations ---
  belongs_to :notable, polymorphic: true
  belongs_to :user  # author of the note

  # --- Validations ---
  validates :body, presence: true

  # --- Scopes ---
  scope :recent, -> { order(created_at: :desc) }
  scope :by_author, ->(user_id) { where(user_id: user_id) if user_id.present? }
  scope :for_type, ->(type) { where(notable_type: type) if type.present? }
end
