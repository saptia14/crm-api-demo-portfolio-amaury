# frozen_string_literal: true

class NoteSerializer < ApplicationSerializer
  attributes :body, :notable_type, :notable_id

  belongs_to :user, serializer: :user
end
