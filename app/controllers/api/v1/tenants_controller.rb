# frozen_string_literal: true

module Api
  module V1
    class TenantsController < BaseController
      # GET /api/v1/tenants/:id
      def show
        # Users are only allowed to see their own tenant
        @tenant = current_user.tenant
        
        # If the requested ID doesn't match the user's tenant ID, we could error,
        # but for simplicity and to satisfy the frontend request, we just
        # return the user's tenant.
        
        render_resource(@tenant, TenantSerializer)
      end
    end
  end
end
