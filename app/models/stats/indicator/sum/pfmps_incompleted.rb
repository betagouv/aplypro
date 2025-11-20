# frozen_string_literal: true

module Stats
  module Indicator
    module Sum
      class PfmpsIncompleted < Stats::Sum
        def initialize(start_year)
          pfmps = Pfmp.for_year(start_year)

          pending_or_null = pfmps
                            .left_outer_joins(:transitions)
                            .where(
                              "(pfmp_transitions.to_state = 'pending' AND " \
                              "pfmp_transitions.most_recent = true) OR " \
                              "pfmp_transitions.to_state IS NULL"
                            )
                            .distinct

          super(
            column: :amount,
            all: pending_or_null
          )
        end

        def self.key
          :pfmps_incompleted_sum
        end

        def self.title
          "Mt. PFMPs incomplètes"
        end

        def self.tooltip_key
          "stats.sum.pfmps_incompleted"
        end

        def global_data
          calculate_theoretical_sum(all)
        end

        def bops_data
          @bops_data ||= calculate_theoretical_sum(group_per_bop(all))
                         .transform_keys { |bop| bop_key_map(bop) }
        end

        def menj_academies_data
          @menj_academies_data ||= calculate_theoretical_sum(group_per_menj_academy(all))
        end

        def establishments_data
          @establishments_data ||= calculate_theoretical_sum(group_per_establishment(all))
        end

        def with_mef_and_establishment
          Pfmp.joins(schooling: { classe: %i[mef establishment school_year] })
        end

        def with_establishment
          Pfmp.joins(schooling: { classe: %i[establishment school_year] })
        end

        private

        def calculate_theoretical_sum(pfmps_relation)
          is_grouped = pfmps_relation.group_values.any?

          base_relation = if is_grouped
                            pfmps_relation.except(:distinct)
                          else
                            Pfmp.where(id: pfmps_relation.select(:id).distinct)
                          end

          result = base_relation
                   .joins(schooling: { classe: :mef })
                   .joins("INNER JOIN wages ON wages.mefstat4 = LEFT(mefs.mefstat11, 4) " \
                          "AND wages.ministry = mefs.ministry " \
                          "AND wages.school_year_id = mefs.school_year_id")
                   .sum("ROUND(((pfmps.end_date - pfmps.start_date)::integer * 5.0 / 7.0)::numeric, 0) " \
                        "* wages.daily_rate")

          return result.to_i if result.is_a?(Numeric)

          result.transform_values(&:to_i)
        end
      end
    end
  end
end
