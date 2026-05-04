# frozen_string_literal: true

module Api
  module V1
    class AnalyticsController < ApplicationController
      def revenue
        authorize :analytics, :revenue?

        render json: {
          data: RevenueAnalyticsService.new(
            scope: policy_scope(Deal),
            params: analytics_params,
            current_user: current_user
          ).call
        }
      end

      def pipeline
        authorize :analytics, :pipeline?

        render json: {
          data: PipelineAnalyticsService.new(
            scope: policy_scope(Deal),
            params: analytics_params
          ).call
        }
      end

      private

      def analytics_params
        params.permit(:granularity, :from, :to, :stage, :user_id)
      end
    end
  end
end
