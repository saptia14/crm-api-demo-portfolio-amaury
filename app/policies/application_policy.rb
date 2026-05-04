# frozen_string_literal: true

# Base application policy for Pundit authorization.
# All resource policies should inherit from this class.
#
# The default behavior is to deny everything. Each resource policy
# must explicitly grant access for each action.
#
# Every policy receives:
#   - user:   the current_user (from Devise)
#   - record: the resource being authorized (e.g., a User, Contact, Deal)
#
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  # Base scope for index queries.
  # Ensures all scoped queries respect tenant boundaries.
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
