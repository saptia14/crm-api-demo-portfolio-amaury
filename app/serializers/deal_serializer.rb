# frozen_string_literal: true

class DealSerializer < ApplicationSerializer
  attributes :name, :amount, :stage, :expected_close_date, :tag_list

  belongs_to :contact, serializer: :contact
  belongs_to :company, serializer: :company
  belongs_to :user, serializer: :user
  has_many :notes, serializer: :note

  attribute :tag_list do |deal|
    deal.tag_list.to_a
  end

  attribute :amount do |deal|
    deal.amount&.to_f
  end
end
