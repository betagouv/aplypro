# frozen_string_literal: true

# Used to fetch live data for the Establishment show page
module Academic
  class EstablishmentStatsQuery
    def initialize(academy_code, school_year)
      @academy_code = academy_code
      @school_year = school_year
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
