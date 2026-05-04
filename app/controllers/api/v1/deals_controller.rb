# frozen_string_literal: true

module Api
  module V1
    class DealsController < BaseController
      before_action :set_deal, only: [:show, :update, :destroy]

      # GET /api/v1/deals
      # Supports segmentation via filter params:
      #   filter[tags]=urgent,enterprise
      #   filter[stage]=prospect
      #   filter[user_id]=1
      #   filter[company_id]=1
      #   filter[created_after]=2026-01-01
      #   filter[created_before]=2026-12-31
      #   filter[q]=big+deal
      def index
        @deals = policy_scope(Deal)
                 .search_and_filter(filter_params)
                 .includes(:contact, :company, :user, :taggings)
                 .by_amount_desc
        authorize Deal

        if request.format.csv?
          send_data CsvExportService.deals(@deals),
                    filename: "deals-#{Date.current}.csv",
                    type: "text/csv"
          return
        end

        render_collection(@deals, DealSerializer)
      end

      # GET /api/v1/deals/:id
      def show
        authorize @deal
        render_resource(@deal, DealSerializer)
      end

      # POST /api/v1/deals
      def create
        @deal = Deal.new(deal_params)
        # Default to current user as the assigned sales rep if not specified
        @deal.user ||= current_user
        authorize @deal

        if @deal.save
          render_resource(@deal, DealSerializer, status: :created)
        else
          render_jsonapi_validation_errors(@deal)
        end
      end

      # PATCH/PUT /api/v1/deals/:id
      def update
        authorize @deal

        if @deal.update(deal_params)
          render_resource(@deal, DealSerializer)
        else
          render_jsonapi_validation_errors(@deal)
        end
      end

      # DELETE /api/v1/deals/:id
      def destroy
        authorize @deal
        @deal.destroy!
        head :no_content
      end

      private

      def set_deal
        @deal = Deal.find(params[:id])
      end

      def deal_params
        params.require(:deal).permit(
          :name, :amount, :stage, :expected_close_date,
          :contact_id, :company_id, :user_id,
          tag_list: []
        )
      end
    end
  end
end
