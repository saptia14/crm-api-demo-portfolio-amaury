# frozen_string_literal: true

module Users
  # Custom Sessions controller for API-only JWT authentication.
  # Handles login (POST /api/v1/login) and logout (DELETE /api/v1/logout).
  #
  # On successful login:
  #   - Returns 200 with serialized user data in JSON:API format
  #   - JWT token is automatically included in the Authorization header by devise-jwt
  #
  # On failed login:
  #   - Returns 401 with JSON:API error format
  #
  # On logout:
  #   - Rotates the user's JTI, invalidating the current token
  #   - Returns 200 with confirmation message
  #
  class SessionsController < Devise::SessionsController
    respond_to :json

    # POST /api/v1/login
    def create
      super
    end

    # DELETE /api/v1/logout
    def destroy
      super
    end

    private

    def respond_with(resource, _opts = {})
      if resource.persisted?
        render json: UserSerializer.new(resource).serializable_hash.to_json,
               status: :ok
      else
        render json: {
          errors: [
            {
              status: "401",
              title: "Invalid Credentials",
              detail: "Invalid email or password."
            }
          ]
        }, status: :unauthorized
      end
    end

    def respond_to_on_destroy
      if current_user
        render json: {
          meta: {
            message: "Logged out successfully."
          }
        }, status: :ok
      else
        render json: {
          errors: [
            {
              status: "401",
              title: "Unauthorized",
              detail: "No active session found."
            }
          ]
        }, status: :unauthorized
      end
    end
  end
end
