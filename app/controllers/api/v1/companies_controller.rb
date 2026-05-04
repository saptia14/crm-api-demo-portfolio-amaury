# frozen_string_literal: true

module Api
  module V1
    class CompaniesController < BaseController
      before_action :set_company, only: [:show, :update, :destroy]

      # GET /api/v1/companies
      def index
        @companies = policy_scope(Company).alphabetical
        authorize Company

        if request.format.csv?
          authorize Company, :export?
          send_data CsvExportService.companies(@companies),
                    filename: "companies-#{Date.current}.csv",
                    type: "text/csv"
          return
        end

        render_collection(@companies, CompanySerializer)
      end

      # GET /api/v1/companies/:id
      def show
        authorize @company
        render_resource(@company, CompanySerializer)
      end

      # POST /api/v1/companies
      def create
        @company = Company.new(company_params)
        authorize @company

        if @company.save
          render_resource(@company, CompanySerializer, status: :created)
        else
          render_jsonapi_validation_errors(@company)
        end
      end

      # PATCH/PUT /api/v1/companies/:id
      def update
        authorize @company

        if @company.update(company_params)
          render_resource(@company, CompanySerializer)
        else
          render_jsonapi_validation_errors(@company)
        end
      end

      # DELETE /api/v1/companies/:id
      def destroy
        authorize @company
        @company.destroy!
        head :no_content
      end

      private

      def set_company
        @company = Company.find(params[:id])
      end

      def company_params
        params.require(:company).permit(:name, :industry, :website)
      end
    end
  end
end
