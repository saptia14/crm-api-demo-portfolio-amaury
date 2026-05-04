# frozen_string_literal: true

class ContactSerializer < ApplicationSerializer
  attributes :first_name, :last_name, :email, :phone, :full_name, :tag_list

  belongs_to :company, serializer: :company
  has_many :deals, serializer: :deal
  has_many :notes, serializer: :note

  attribute :full_name do |contact|
    contact.full_name
  end

  attribute :tag_list do |contact|
    contact.tag_list.to_a
  end
end
