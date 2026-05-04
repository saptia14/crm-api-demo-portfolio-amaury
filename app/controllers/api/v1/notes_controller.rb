# frozen_string_literal: true

module Api
  module V1
    class NotesController < BaseController
      before_action :set_notable, only: [:index, :create]
      before_action :set_note, only: [:show, :update, :destroy]

      # GET /api/v1/contacts/:contact_id/notes
      # GET /api/v1/deals/:deal_id/notes
      # GET /api/v1/companies/:company_id/notes
      def index
        @notes = policy_scope(@notable.notes).recent
        authorize Note

        render_collection(@notes, NoteSerializer)
      end

      # GET /api/v1/notes/:id
      def show
        authorize @note
        render_resource(@note, NoteSerializer)
      end

      # POST /api/v1/contacts/:contact_id/notes
      # POST /api/v1/deals/:deal_id/notes
      # POST /api/v1/companies/:company_id/notes
      def create
        @note = @notable.notes.build(note_params)
        @note.user = current_user
        authorize @note

        if @note.save
          render_resource(@note, NoteSerializer, status: :created)
        else
          render_jsonapi_validation_errors(@note)
        end
      end

      # PATCH/PUT /api/v1/notes/:id
      def update
        authorize @note

        if @note.update(note_params)
          render_resource(@note, NoteSerializer)
        else
          render_jsonapi_validation_errors(@note)
        end
      end

      # DELETE /api/v1/notes/:id
      def destroy
        authorize @note
        @note.destroy!
        head :no_content
      end

      private

      def set_notable
        if params[:contact_id]
          @notable = Contact.find(params[:contact_id])
        elsif params[:deal_id]
          @notable = Deal.find(params[:deal_id])
        elsif params[:company_id]
          @notable = Company.find(params[:company_id])
        end
      end

      def set_note
        @note = Note.find(params[:id])
      end

      def note_params
        params.require(:note).permit(:body)
      end
    end
  end
end
