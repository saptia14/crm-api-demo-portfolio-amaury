# frozen_string_literal: true

class AnalyticsPolicy < ApplicationPolicy
  def revenue?
    true
  end

  def pipeline?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
