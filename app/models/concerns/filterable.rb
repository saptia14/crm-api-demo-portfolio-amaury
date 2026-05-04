# frozen_string_literal: true

# Shared filtering/segmentation logic for models that support
# tag-based and attribute-based segmentation.
#
# Include this concern in any model that needs search_and_filter:
#   include Filterable
#
# Usage in controllers:
#   @contacts = policy_scope(Contact).search_and_filter(params)
#
module Filterable
  extend ActiveSupport::Concern

  class_methods do
    # Generic search and filter method that accepts a params hash.
    # Builds a query chain based on provided filter parameters.
    #
    # Supported filters:
    #   - tags:       Comma-separated tag names (e.g., "urgent,enterprise")
    #   - stage:      Deal stage (for Deal model only)
    #   - status:     Alias for stage
    #   - created_after:  ISO 8601 date string
    #   - created_before: ISO 8601 date string
    #   - company_id: Filter by company
    #   - user_id:    Filter by assigned user (deals)
    #   - q:          Free-text search on name/email fields
    #
    def search_and_filter(params = {})
      results = all

      # --- Tag filtering ---
      if params[:tags].present?
        tag_list = params[:tags].split(",").map(&:strip)
        results = results.tagged_with(tag_list, any: true)
      end

      # --- Stage/Status filtering ---
      if column_names.include?("stage")
        stage_value = params[:stage].presence || params[:status].presence

        if stage_value.present?
          case stage_value.to_s
          when "open"
            results = results.where(stage: %i[prospect qualification proposal])
          when "closed"
            results = results.where(stage: %i[won lost])
          else
            results = results.where(stage: stage_value)
          end
        end
      end

      # --- Date range filtering ---
      if params[:created_after].present?
        results = results.where("#{table_name}.created_at >= ?", params[:created_after].to_date.beginning_of_day)
      end

      if params[:created_before].present?
        results = results.where("#{table_name}.created_at <= ?", params[:created_before].to_date.end_of_day)
      end

      # --- Association filtering ---
      if params[:company_id].present? && column_names.include?("company_id")
        results = results.where(company_id: params[:company_id])
      end

      if params[:user_id].present? && column_names.include?("user_id")
        results = results.where(user_id: params[:user_id])
      end

      # --- Free-text search ---
      if params[:q].present?
        query = "%#{params[:q].downcase}%"
        if column_names.include?("email")
          results = results.where(
            "LOWER(#{table_name}.first_name) LIKE :q OR " \
            "LOWER(#{table_name}.last_name) LIKE :q OR " \
            "LOWER(#{table_name}.email) LIKE :q",
            q: query
          )
        elsif column_names.include?("name")
          results = results.where("LOWER(#{table_name}.name) LIKE ?", query)
        end
      end

      results
    end
  end
end
