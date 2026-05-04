# frozen_string_literal: true

module Api
  module V1
    module Users
      class RolesController < BaseController
        before_action :set_user

        def update
          # Authorize the action against the target user
          authorize @target_user, :update_role?

          if @target_user.update(role_params)
            render_resource(@target_user, UserSerializer)
          else
            render_jsonapi_validation_errors(@target_user)
          end
        end

        private

        def set_user
          # acts_as_tenant will automatically scope this to the current tenant
          @target_user = User.find(params[:user_id])
        end

        def role_params
          # Strong parameters for role update
          params.require(:user).permit(:role)
        end
      end
    end
  end
end
