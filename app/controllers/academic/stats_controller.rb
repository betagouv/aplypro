# frozen_string_literal: true

module Academic
  class StatsController < Academic::ApplicationController
    def index
      @current_year = selected_school_year.start_year
      @report = find_report
      @stats = Stats::Main.new(@current_year)

      prepare_statistics_data if @report
    end

    private

    def find_report
      report_id = params[:report_id]
      return Report.find(report_id) if report_id.present?

      Report.latest
    end

    def prepare_statistics_data
      @academy_stats = academy_statistics
      @global_data = @report.data["global_data"]
      @bops_data = @report.data["bops_data"]
      @menj_academies_data = @report.data["menj_academies_data"]
      @establishments_data = filtered_establishments_data_from_report
    end

    def academy_statistics
      establishments = current_academy_establishments
      establishment_ids = establishments.pluck(:id)

      build_statistics_hash(establishments, establishment_ids)
    end

    def build_statistics_hash(establishments, establishment_ids)
      {
        total_establishments: establishments.count,
        total_students: count_students(establishment_ids),
        total_pfmps: count_pfmps(establishment_ids),
        validated_pfmps: count_validated_pfmps(establishment_ids),
        total_validated_amount: sum_validated_amounts(establishment_ids),
        total_paid_amount: sum_paid_amounts(establishment_ids)
      }
    end

    def current_academy_establishments
      Establishment.joins(:classes)
                   .where(academy_code: selected_academy,
                          "classes.school_year_id": selected_school_year)
                   .distinct
    end

    def count_students(establishment_ids)
      Schooling.joins(:classe)
               .where(base_conditions(establishment_ids))
               .count
    end

    def count_pfmps(establishment_ids)
      pfmp_base_scope(establishment_ids).count
    end

    def count_validated_pfmps(establishment_ids)
      validated_pfmps_scope(establishment_ids).count
    end

    def sum_validated_amounts(establishment_ids)
      validated_pfmps_scope(establishment_ids).sum(:amount)
    end

    def sum_paid_amounts(establishment_ids)
      Pfmp.joins(schooling: { classe: :school_year },
                 payment_requests: :asp_payment_request_transitions)
          .where(base_conditions(establishment_ids)
                 .merge(asp_payment_request_transitions: { to_state: "paid",
                                                           most_recent: true }))
          .sum(:amount)
    end

    def base_conditions(establishment_ids)
      { classes: { school_year_id: selected_school_year,
                   establishment_id: establishment_ids } }
    end

    def pfmp_base_scope(establishment_ids)
      Pfmp.joins(schooling: { classe: :school_year })
          .where(base_conditions(establishment_ids))
    end

    def validated_pfmps_scope(establishment_ids)
      pfmp_base_scope(establishment_ids)
        .joins(:transitions)
        .where(pfmp_transitions: { to_state: "validated", most_recent: true })
    end

    def filtered_establishments_data_from_report
      full_data = @report.data["establishments_data"]
      filter_establishments_data(full_data)
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
  end
end
