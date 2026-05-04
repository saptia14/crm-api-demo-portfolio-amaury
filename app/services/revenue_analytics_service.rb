# frozen_string_literal: true

class RevenueAnalyticsService
  VALID_GRANULARITIES = %w[hour day month year].freeze
  VALID_STAGES = %w[all open won lost].freeze

  def initialize(scope:, params:, current_user:)
    @scope = scope
    @params = params
    @current_user = current_user
  end

  def call
    {
      granularity: granularity,
      stage: stage,
      from: from.iso8601,
      to: to.iso8601,
      series: series,
      totals: totals
    }
  end

  private

  attr_reader :scope, :params, :current_user

  def granularity
    @granularity ||= VALID_GRANULARITIES.include?(params[:granularity].to_s) ? params[:granularity].to_s : "month"
  end

  def stage
    @stage ||= VALID_STAGES.include?(params[:stage].to_s) ? params[:stage].to_s : "won"
  end

  def from
    @from ||= parse_time(params[:from]) || 12.months.ago
  end

  def to
    @to ||= parse_time(params[:to]) || Time.zone.now
  end

  def filtered_scope
    @filtered_scope ||= begin
      results = scope.where(created_at: from..to)
      results = results.where(user_id: params[:user_id]) if params[:user_id].present?

      case stage
      when "open"
        results.open_deals
      when "won"
        results.where(stage: :won)
      when "lost"
        results.where(stage: :lost)
      else
        results
      end
    end
  end

  def series
    amounts_by_period = grouped_amounts
    counts_by_period = grouped_counts

    buckets.map do |bucket|
      {
        period: format_period(bucket),
        amount: amounts_by_period[bucket] || 0,
        count: counts_by_period[bucket] || 0
      }
    end
  end

  def totals
    {
      amount: filtered_scope.sum(:amount).to_f,
      count: filtered_scope.count
    }
  end

  def grouped_amounts
    @grouped_amounts ||= filtered_scope
                         .group(Arel.sql(period_expression))
                         .sum(:amount)
                         .each_with_object({}) do |(period, amount), memo|
                           memo[normalize_period(period)] = amount.to_f
                         end
  end

  def grouped_counts
    @grouped_counts ||= filtered_scope
                        .group(Arel.sql(period_expression))
                        .count
                        .each_with_object({}) do |(period, count), memo|
                          memo[normalize_period(period)] = count
                        end
  end

  def buckets
    @buckets ||= begin
      current = normalize_period(from)
      final = normalize_period(to)
      periods = []

      while current <= final
        periods << current
        current = advance_period(current)
      end

      periods
    end
  end

  def period_expression
    case granularity
    when "hour"
      "date_trunc('hour', deals.created_at)"
    when "day"
      "date_trunc('day', deals.created_at)"
    when "year"
      "date_trunc('year', deals.created_at)"
    else
      "date_trunc('month', deals.created_at)"
    end
  end

  def normalize_period(time)
    time = Time.zone.parse(time.to_s) unless time.respond_to?(:in_time_zone)
    time = time.in_time_zone

    case granularity
    when "hour"
      time.beginning_of_hour
    when "day"
      time.beginning_of_day
    when "year"
      time.beginning_of_year
    else
      time.beginning_of_month
    end
  end

  def advance_period(time)
    case granularity
    when "hour"
      time + 1.hour
    when "day"
      time + 1.day
    when "year"
      time + 1.year
    else
      time.advance(months: 1)
    end
  end

  def format_period(time)
    case granularity
    when "hour"
      time.strftime("%Y-%m-%d %H:00")
    when "day"
      time.strftime("%Y-%m-%d")
    when "year"
      time.strftime("%Y")
    else
      time.strftime("%Y-%m")
    end
  end

  def parse_time(value)
    return if value.blank?

    Time.zone.parse(value.to_s)
  rescue ArgumentError, TypeError
    nil
  end
end
