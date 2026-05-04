# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Pundit::Authorization

  # --- Authentication ---
  # Require JWT authentication for all controllers by default.
  # Individual controllers can skip this with:
  #   skip_before_action :authenticate_user!
  before_action :authenticate_user!

  # --- Multitenancy ---
  # Set the current tenant from the authenticated user.
  # This replaces the Phase 1 temporary tenant assignment.
  before_action :set_tenant_from_current_user

  # --- Authorization ---
  # Rescue from Pundit authorization failures with a 403 JSON:API error.
  rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized

  private

  # =========================================================================
  # Multitenancy
  # =========================================================================

  # Set the current tenant based on the authenticated user's tenant.
  # This ensures all queries are automatically scoped to the user's tenant.
  #
  # For unauthenticated requests (e.g., login/signup), this is skipped
  # because authenticate_user! will reject the request first, and Devise
  # controllers skip this callback.
  def set_tenant_from_current_user
    return unless current_user

    ActsAsTenant.current_tenant = current_user.tenant
  end

  # =========================================================================
  # JSON:API Error Helpers
  # =========================================================================

  def render_jsonapi_error(status:, title:, detail:, source_pointer: nil)
    error = {
      status: status.to_s,
      title: title,
      detail: detail
    }
    error[:source] = { pointer: source_pointer } if source_pointer

    render json: { errors: [error] }, status: status
  end

  def render_jsonapi_validation_errors(record)
    errors = record.errors.map do |error|
      {
        status: "422",
        source: { pointer: "/data/attributes/#{error.attribute}" },
        title: "Invalid Attribute",
        detail: error.full_message
      }
    end

    render json: { errors: errors }, status: :unprocessable_entity
  end

  # =========================================================================
  # Authorization Error Handler
  # =========================================================================

  def handle_unauthorized(exception)
    render json: {
      errors: [
        {
          status: "403",
          title: "Forbidden",
          detail: "You are not authorized to perform this action.",
          meta: {
            policy: exception.policy.class.to_s,
            query: exception.query
          }
        }
      ]
    }, status: :forbidden
  end
end
