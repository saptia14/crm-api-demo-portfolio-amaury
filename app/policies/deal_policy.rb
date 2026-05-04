# frozen_string_literal: true

# Authorization policy for Deal resources.
# Admins and managers can perform all actions on all deals.
# Sales reps can view all deals, create deals, and update/destroy their own.
#
class DealPolicy < ApplicationPolicy
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
    user.admin? || user.manager? || own_deal?
  end

  def destroy?
    user.admin? || (user.manager? && !record.won?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin? || user.manager?
        scope.all
      else
        # Sales reps only see their own deals
        scope.where(user_id: user.id)
      end
    end
  end

  private

  def own_deal?
    record.user_id == user.id
  end
end
