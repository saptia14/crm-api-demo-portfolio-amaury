# frozen_string_literal: true

# Authorization policy for Note resources.
# All roles can view notes on resources they can access.
# All roles can create notes.
# Users can update/destroy their own notes.
# Admins can update/destroy any note.
#
class NotePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def update?
    user.admin? || own_note?
  end

  def destroy?
    user.admin? || own_note?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  private

  def own_note?
    record.user_id == user.id
  end
end
