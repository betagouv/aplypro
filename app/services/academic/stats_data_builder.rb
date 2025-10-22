# frozen_string_literal: true

module Academic
  class StatsDataBuilder
    def initialize(academy_code, school_year)
      @academy_code = academy_code
      @school_year = school_year
    end

    def current_academy_establishments
      Establishment.joins(:classes)
                   .where(academy_code: @academy_code,
                          "classes.school_year_id": @school_year)
                   .distinct
    end

    def calculate_academy_stats(report)
      establishments = current_academy_establishments
      establishment_ids = establishments.pluck(:id)
      calculator = StatsProgressionCalculator.new(report, @academy_code, {})
      calculator.calculate_current_stats(establishments, establishment_ids, @school_year)
    end

    def filter_establishments_data(full_data)
      titles = full_data.first
      establishment_rows = full_data[1..]

      academy_establishments = current_academy_establishments.pluck(:uai)

      filtered_rows = establishment_rows.select do |row|
        uai = row[0]
        academy_establishments.include?(uai)
      end

      [titles, *filtered_rows]
    end

    def calculate_progressions(report, academy_stats)
      StatsProgressionCalculator.new(report, @academy_code, academy_stats).calculate
    end

    def establishments_data_summary(establishment_ids)
      data = {}
      Establishment.where(id: establishment_ids).find_each do |establishment|
        data[establishment.uai] = build_establishment_data(establishment)
      end
      data.sort_by { |_uai, etab_data| -etab_data[:paid_amount] }.to_h
    end

    private

    def build_establishment_data(establishment)
      pfmps = establishment_pfmps(establishment)

      establishment.attributes.symbolize_keys.merge(
        schooling_count: establishment.schoolings.count,
        payable_amount: validated_amount(pfmps),
        paid_amount: paid_amount(pfmps)
      )
    end

    def establishment_pfmps(establishment)
      establishment.pfmps
                   .joins(schooling: { classe: :school_year })
                   .where(classes: { school_year_id: @school_year })
    end

    def validated_amount(pfmps)
      pfmps.joins(:transitions)
           .where(pfmp_transitions: { to_state: "validated", most_recent: true })
           .sum(:amount)
    end

    def paid_amount(pfmps)
      pfmps.joins(payment_requests: :asp_payment_request_transitions)
           .where(asp_payment_request_transitions: { to_state: "paid", most_recent: true })
           .sum(:amount)
    end
  end
end
