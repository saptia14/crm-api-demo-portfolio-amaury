# frozen_string_literal: true

# Authorization policy for Company resources.
# All roles can view companies within their tenant.
# Only admins and managers can create/update/destroy.
#
class CompanyPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.admin? || user.manager?
  end

  def update?
    user.admin? || user.manager?
  end

  def destroy?
    user.admin?
  end
  
  def export?
    user.admin? || user.manager?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
