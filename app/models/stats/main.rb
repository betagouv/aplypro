# frozen_string_literal: true

module Stats
  class Main # rubocop:disable Metrics/ClassLength
    attr_reader :indicators

    INDICATOR_CLASSES = [
      Indicator::Count::AttributiveDecisions,
      Indicator::Count::Pfmps,
      Indicator::Count::PfmpsCompleted,
      Indicator::Count::PfmpsIncompleted,
      Indicator::Count::PfmpsPaid,
      Indicator::Count::PfmpsPayable,
      Indicator::Count::PfmpsExtended,
      Indicator::Count::PfmpsValidated,
      Indicator::Count::Ribs,
      Indicator::Count::Schoolings,
      Indicator::Count::Students,
      Indicator::Count::StudentsData,
      Indicator::Count::StudentsPaid,
      Indicator::Count::PaymentRequestsSent,
      Indicator::Count::PaymentRequestsIntegrated,
      Indicator::Count::PaymentRequestsPaid,
      Indicator::Ratio::AttributiveDecisions,
      Indicator::Ratio::PfmpsPaidPayable,
      Indicator::Ratio::PfmpsValidated,
      Indicator::Ratio::Ribs,
      Indicator::Ratio::StudentsData,
      Indicator::Ratio::StudentsPaid,
      Indicator::Sum::PaymentRequestsRecovery,
      Indicator::Sum::PaymentRequestsPaid,
      Indicator::Sum::PfmpsCompleted,
      Indicator::Sum::PfmpsIncompleted,
      Indicator::Sum::PfmpsExtended,
      Indicator::Sum::PfmpsValidated,
      Indicator::Sum::Yearly
    ].freeze

    def self.indicators_metadata
      @indicators_metadata ||= begin
        indicators_map = INDICATOR_CLASSES.index_by(&:key)

        Report::HEADERS.map do |key|
          indicator_class = indicators_map[key]
          next unless indicator_class

          {
            title: indicator_class.title,
            tooltip_key: indicator_class.tooltip_key,
            type: indicator_class.superclass.name
          }
        end
      end
    end

    def initialize(start_year)
      @school_year = SchoolYear.find_by!(start_year:)
      @indicators = build_indicators(start_year)
    end

    def method_missing(method)
      return super unless method.to_s.ends_with?("_data_csv")

      csv_of(send(data_method_name(method)))
    end

    def respond_to_missing?(method, include_all = false)
      (method.to_s.end_with?("_data_csv") && super(data_method_name(method), include_all)) || super
    end

    def data_method_name(csv_method_name)
      csv_method_name.to_s.split("_csv").first.to_sym
    end

    def csv_of(data)
      data.map { |row| row.map { |cell| format_cell_for_csv(cell) }.join("\t") }.join("\n")
    end

    def global_data
      [indicators.transform_values(&:global_data)]
    end

    def bops_data
      %w[ENPU ENPR MASA MER].map do |bop|
        initialize_indicators({ bop: bop }, :bops_data)
      end
    end

    def menj_academies_data
      academies.map do |academy|
        initialize_indicators({ academy: academy }, :menj_academies_data)
      end
    end

    def establishments_data
      establishments.map do |uai, name, academy, private_code, ministry|
        specific_indicators = {
          uai: uai,
          establishment_name: name,
          ministry: ministry,
          academy: academy,
          private_or_public: format_private_status(private_code)
        }
        initialize_indicators(specific_indicators, :establishments_data)
      end
    end

    private

    def build_indicators(start_year)
      indicators = {}
      build_count_indicators(indicators, start_year)
      build_sum_indicators(indicators, start_year)
      build_ratio_indicators(indicators)
      indicators
    end

    def build_count_indicators(indicators, start_year)
      Stats::Count.descendants.each do |indicator_class|
        indicators[indicator_class.key] = indicator_class.new(start_year)
      end
    end

    def build_sum_indicators(indicators, start_year)
      Stats::Sum.descendants.each do |indicator_class|
        indicators[indicator_class.key] = indicator_class.new(start_year)
      end
    end

    def build_ratio_indicators(indicators)
      Stats::Ratio.descendants.each do |indicator_class|
        dependencies = indicator_class.dependencies.transform_values { |key| indicators[key] }
        indicators[indicator_class.key] = indicator_class.new(**dependencies)
      end
    end

    def format_cell_for_csv(cell)
      cell.is_a?(Float) || cell.nil? ? number_string(cell) : cell
    end

    def academies
      Establishment.distinct
                   .order(:academy_label)
                   .reject { |e| Exclusion.establishment_excluded?(e.uai, school_year: @school_year) }
                   .map(&:academy_label).uniq
    end

    def establishments
      Establishment.distinct
                   .order(:uai)
                   .reject { |e| Exclusion.establishment_excluded?(e.uai, school_year: @school_year) }
                   .map { |e| [e.uai, e.name, e.academy_label, e.private_contract_type_code, e.ministry] }
    end

    def initialize_indicators(specific_indicators, method)
      id = specific_indicators.values.first

      all_indicators = specific_indicators.merge!(indicators)

      all_indicators.transform_values do |indicator|
        indicator.send(method)[id]
      rescue NoMethodError
        indicator
      end
    end

    def format_private_status(private_code)
      private_code == "99" ? "Public" : "Privé"
    end

    def number_string(ratio)
      return 0 if ratio.nil? || ratio.nan?
      return "Infini" if ratio.infinite?

      ratio.to_s.gsub(".", ",")
    end
  end
end
