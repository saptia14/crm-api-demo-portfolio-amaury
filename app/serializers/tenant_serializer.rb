# frozen_string_literal: true

class TenantSerializer < ApplicationSerializer
  attributes :name, :subdomain, :active
end
