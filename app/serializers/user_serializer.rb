# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  attributes :email, :first_name, :last_name, :role, :full_name

  # Include tenant relationship in JSON:API format
  belongs_to :tenant, serializer: TenantSerializer

  attribute :full_name do |user|
    user.full_name
  end
end
