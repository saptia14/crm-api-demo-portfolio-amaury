# frozen_string_literal: true

# Authorization policy for Contact resources.
# All roles can view contacts within their tenant.
# All roles can create contacts.
# Admins and managers can update/destroy any contact.
# Sales reps can update contacts but not destroy them.
#
class ContactPolicy < ApplicationPolicy
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
    true
  end

  def destroy?
    user.admin? || user.manager?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
