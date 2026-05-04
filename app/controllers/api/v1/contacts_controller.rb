# frozen_string_literal: true

module Api
  module V1
    class ContactsController < BaseController
      before_action :set_contact, only: [:show, :update, :destroy]

      # GET /api/v1/contacts
      # Supports segmentation via filter params:
      #   filter[tags]=urgent,enterprise
      #   filter[company_id]=1
      #   filter[created_after]=2026-01-01
      #   filter[created_before]=2026-12-31
      #   filter[q]=john
      def index
        @contacts = policy_scope(Contact)
                    .search_and_filter(filter_params)
                    .includes(:company, :taggings)
                    .alphabetical
        authorize Contact

        if request.format.csv?
          send_data CsvExportService.contacts(@contacts),
                    filename: "contacts-#{Date.current}.csv",
                    type: "text/csv"
          return
        end

        render_collection(@contacts, ContactSerializer)
      end

      # GET /api/v1/contacts/:id
      def show
        authorize @contact
        render_resource(@contact, ContactSerializer)
      end

      # POST /api/v1/contacts
      def create
        @contact = Contact.new(contact_params)
        authorize @contact

        if @contact.save
          render_resource(@contact, ContactSerializer, status: :created)
        else
          render_jsonapi_validation_errors(@contact)
        end
      end

      # PATCH/PUT /api/v1/contacts/:id
      def update
        authorize @contact

        if @contact.update(contact_params)
          render_resource(@contact, ContactSerializer)
        else
          render_jsonapi_validation_errors(@contact)
        end
      end

      # DELETE /api/v1/contacts/:id
      def destroy
        authorize @contact
        @contact.destroy!
        head :no_content
      end

      private

      def set_contact
        @contact = Contact.find(params[:id])
      end

      def contact_params
        params.require(:contact).permit(
          :first_name, :last_name, :email, :phone, :company_id,
          tag_list: []
        )
      end
    end
  end
end
