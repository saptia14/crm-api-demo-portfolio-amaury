# frozen_string_literal: true

class PaymentPolicy < ApplicationPolicy
  # Only administrators can manage tenant financial transactions.
  def process?
    user.admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
