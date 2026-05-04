# frozen_string_literal: true

module Api
  module V1
    # Base controller for all API v1 resource controllers.
    # Inherits authentication, tenant resolution, and Pundit from ApplicationController.
    # Provides shared pagination and JSON:API response helpers.
    class BaseController < ApplicationController
      # --- Pagination ---
      # Default pagination parameters matching JSON:API spec
      DEFAULT_PAGE_SIZE = 25
      MAX_PAGE_SIZE = 50

      # --- JSON:API Body Parsing ---
      # Ember Data and any spec-compliant JSON:API client sends bodies in
      # the form `{ data: { type: 'contact', attributes: { ... },
      # relationships: { company: { data: { type: 'company', id: '5' } } } } }`.
      #
      # Our resource controllers use `params.require(:contact).permit(...)`
      # for `strong_parameters`. We bridge the two by extracting the
      # JSON:API payload (when present) into a flat top-level key matching
      # the resource type _before_ controllers run their `*_params` methods.
      #
      # If the request already has the flat key (e.g. legacy clients or our
      # own RSpec request specs), we leave it alone.
      before_action :unwrap_jsonapi_payload

      private

      def unwrap_jsonapi_payload
        return if params[:data].blank?
        return unless request.post? || request.patch? || request.put?

        data = params[:data]
        type = data[:type].to_s
        return if type.blank?

        # JSON:API resource types are typically dasherized & pluralized
        # ("contacts"); the controller key is singular & underscored
        # ("contact"). Try a few normalizations.
        resource_key = type.singularize.underscore.to_sym
        return if params[resource_key].present?

        flat = (data[:attributes] || {}).to_unsafe_h.symbolize_keys

        # Map relationships → *_id (single) or *_ids (collection).
        (data[:relationships] || {}).each do |relation_name, relation_payload|
          rel_data = relation_payload.is_a?(ActionController::Parameters) ?
            relation_payload[:data] : relation_payload['data']
          next if rel_data.nil?

          if rel_data.is_a?(Array) || rel_data.is_a?(ActionController::Parameters) && rel_data.respond_to?(:each_with_index) && rel_data[0]
            ids = rel_data.map { |r| r[:id] }
            flat["#{relation_name.to_s.underscore.singularize}_ids".to_sym] = ids
          else
            flat["#{relation_name.to_s.underscore}_id".to_sym] = rel_data[:id]
          end
        end

        params[resource_key] = ActionController::Parameters.new(flat)
      end

      def page_number
        params.dig(:page, :number)&.to_i || 1
      end

      def page_size
        size = params.dig(:page, :size)&.to_i || DEFAULT_PAGE_SIZE
        [size, MAX_PAGE_SIZE].min
      end

      def paginate(scope)
        scope.limit(page_size).offset((page_number - 1) * page_size)
      end

      def pagination_meta(scope)
        total = scope.count
        {
          total: total,
          pages: (total.to_f / page_size).ceil,
          page: page_number,
          per_page: page_size
        }
      end

      # Render a paginated JSON:API collection
      def render_collection(scope, serializer, meta: {})
        total_scope = scope
        paginated = paginate(scope)

        render json: serializer.new(
          paginated,
          meta: pagination_meta(total_scope).merge(meta)
        ).serializable_hash.to_json
      end

      # Render a single JSON:API resource
      def render_resource(resource, serializer, status: :ok)
        render json: serializer.new(resource).serializable_hash.to_json,
               status: status
      end

      # Permitted filter params for search_and_filter
      def filter_params
        params.fetch(:filter, {}).permit(
          :tags, :stage, :status, :company_id, :user_id, :q,
          :created_after, :created_before
        )
      end
    end
  end
end
