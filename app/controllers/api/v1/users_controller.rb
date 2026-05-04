# frozen_string_literal: true

module Api
  module V1
    class UsersController < BaseController
      # GET /api/v1/users
      def index
        @users = policy_scope(User)
        authorize User

        render_collection(@users, UserSerializer)
      end

      # GET /api/v1/users/:id
      def show
        @user = User.find(params[:id])
        authorize @user

        render_resource(@user, UserSerializer)
      end

      # GET /api/v1/users/me
      # Returns the currently authenticated user's profile.
      def me
        render json: UserSerializer.new(current_user).serializable_hash.to_json,
               content_type: 'application/vnd.api+json'
      end

      # PATCH/PUT /api/v1/users/:id
      def update
        @user = User.find(params[:id])
        authorize @user, :update_role?

        if @user.update(user_params)
          render_resource(@user, UserSerializer)
        else
          render_jsonapi_validation_errors(@user)
        end
      end

      private

      def user_params
        params.require(:user).permit(:role, :first_name, :last_name)
      end
    end
  end
end
