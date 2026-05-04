# frozen_string_literal: true

module Users
  # Custom Registrations controller for API-only user sign-up.
  # Handles registration (POST /api/v1/signup).
  #
  # On successful registration:
  #   - Returns 201 with serialized user data in JSON:API format
  #   - JWT token is automatically included in the Authorization header by devise-jwt
  #
  # On failed registration:
  #   - Returns 422 with JSON:API validation errors
  #
  # Registration requires a tenant_id to be provided. Every user MUST belong
  # to a tenant. The tenant_id is validated at both the model and database level.
  #
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json

    # POST /api/v1/signup
    def create
      build_resource(sign_up_params)

      resource.save
      yield resource if block_given?

      if resource.persisted?
        # Sign in the user and issue JWT token
        sign_up(resource_name, resource)

        render json: UserSerializer.new(resource).serializable_hash.to_json,
               status: :created
      else
        clean_up_passwords resource
        set_minimum_password_length

        render json: {
          errors: resource.errors.map { |error|
            {
              status: "422",
              source: { pointer: "/data/attributes/#{error.attribute}" },
              title: "Invalid Attribute",
              detail: error.full_message
            }
          }
        }, status: :unprocessable_entity
      end
    end

    private

    # Permit tenant_id, role, and profile fields in addition to Devise defaults.
    # Note: In production, you may want to restrict role assignment to admins only
    # and remove :role from sign_up_params.
    def sign_up_params
      params.require(:user).permit(
        :email, :password, :password_confirmation,
        :tenant_id, :role, :first_name, :last_name
      )
    end
  end
end
