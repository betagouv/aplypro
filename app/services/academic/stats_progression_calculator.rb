# frozen_string_literal: true

module Academic
  class StatsProgressionCalculator
    def initialize(current_report, academy_code, current_stats)
      @current_report = current_report
      @academy_code = academy_code
      @current_stats = current_stats
    end

    def calculate
      return {} unless @current_report.previous_report

      previous_stats = calculate_previous_stats
      calculate_progressions(previous_stats)
    end

    def calculate_current_stats(establishments, establishment_ids, school_year)
      build_stats_hash(establishments, establishment_ids, school_year)
    end

    private

    def calculate_previous_stats
      previous_report = @current_report.previous_report
      establishments = Establishment.joins(:classes)
                                    .where(academy_code: @academy_code,
                                           "classes.school_year_id": previous_report.school_year)
                                    .distinct
      establishment_ids = establishments.pluck(:id)

      build_stats_hash(establishments, establishment_ids, previous_report.school_year)
    end

    def calculate_progressions(previous_stats)
      progressions = {}
      @current_stats.each do |key, current_value|
        previous_value = previous_stats[key]
        next if previous_value.nil? || previous_value.zero?

        progression = ((current_value.to_f - previous_value.to_f) / previous_value.to_f * 100).round(1)
        progressions[key] = progression unless progression.zero?
      end
      progressions
    end

    def build_stats_hash(establishments, establishment_ids, school_year)
      base_conditions = { classes: { school_year_id: school_year, establishment_id: establishment_ids } }
      pfmp_base = Pfmp.joins(schooling: { classe: :school_year }).where(base_conditions)
      validated_pfmps = pfmp_base.joins(:transitions)
                                 .where(pfmp_transitions: { to_state: "validated", most_recent: true })
      paid_conditions = base_conditions.merge(
        asp_payment_request_transitions: { to_state: "paid", most_recent: true }
      )

      {
        total_establishments: establishments.count,
        total_students: Schooling.joins(:classe).where(base_conditions).count,
        total_pfmps: pfmp_base.count,
        validated_pfmps: validated_pfmps.count,
        total_validated_amount: validated_pfmps.sum(:amount),
        total_paid_amount: Pfmp.joins(schooling: { classe: :school_year },
                                      payment_requests: :asp_payment_request_transitions)
                               .where(paid_conditions)
                               .sum(:amount)
      }
    end
  end
end
