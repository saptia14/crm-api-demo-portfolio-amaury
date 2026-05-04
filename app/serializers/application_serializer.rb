# frozen_string_literal: true

# Base serializer class for all JSON:API serializers in the application.
# All resource serializers should inherit from this class to ensure
# consistent JSON:API formatting across the entire API.
#
# Usage:
#   class ContactSerializer < ApplicationSerializer
#     attributes :first_name, :last_name, :email
#     belongs_to :tenant
#     has_many :deals
#   end
#
class ApplicationSerializer
  include JSONAPI::Serializer

  # Ensure all serializers output meta information by default.
  # This can be customized per serializer.
  meta do |record|
    {
      created_at: record.respond_to?(:created_at) ? record.created_at&.iso8601 : nil,
      updated_at: record.respond_to?(:updated_at) ? record.updated_at&.iso8601 : nil
    }
  end
end
