# frozen_string_literal: true

class CompanySerializer < ApplicationSerializer
  attributes :name, :industry, :website

  has_many :contacts, serializer: :contact
  has_many :deals, serializer: :deal
end
