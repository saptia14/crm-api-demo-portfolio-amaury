# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    # All authenticated users can see the team list in their tenant
    true
  end

  def show?
    index?
  end

  def update_role?
    # 1. Must be a super_admin
    return false unless user.super_admin?

    # 2. Cannot modify themselves
    return false if user.id == record.id

    # 3. Cannot modify OTHER super_admins (except maybe by a higher power, 
    # but for this app we'll keep it simple: no super_admin touch each other)
    return false if record.super_admin?

    # 4. Strict tenant boundary check
    record.tenant_id == user.tenant_id
  end

  # Ensure the scope only returns users within the current tenant
  class Scope < Scope
    def resolve
      # acts_as_tenant naturally scopes this, but explicitly defining it 
      # here keeps the policy self-documenting.
      scope.where(tenant_id: user.tenant_id)
    end
  end
end
