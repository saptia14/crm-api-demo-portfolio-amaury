# frozen_string_literal: true

class PipelineAnalyticsService
  def initialize(scope:, params: {})
    @scope = scope
    @params = params
  end

  def call
    counts_by_stage = filtered_scope.group(:stage).count
    amount_by_stage = filtered_scope.group(:stage).sum(:amount)

    {
      stages: Deal.stages.keys.map do |stage_name|
        stage_key = Deal.stages[stage_name]
        {
          stage: stage_name,
          count: counts_by_stage[stage_name] || counts_by_stage[stage_key] || 0,
          amount: (amount_by_stage[stage_name] || amount_by_stage[stage_key]).to_f
        }
      end
    }
  end

  private

  attr_reader :scope, :params

  def filtered_scope
    results = scope
    results = results.where(created_at: from..to) if from && to
    results = results.where(user_id: params[:user_id]) if params[:user_id].present?
    results
  end

  def from
    @from ||= parse_time(params[:from])
  end

  def to
    @to ||= parse_time(params[:to])
  end

  def parse_time(value)
    return if value.blank?

    Time.zone.parse(value.to_s)
  rescue ArgumentError, TypeError
    nil
  end
end
