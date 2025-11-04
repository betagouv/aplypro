# frozen_string_literal: true

module Stats
  class Main # rubocop:disable Metrics/ClassLength
    attr_reader :indicators

    def initialize(start_year)
      @school_year = SchoolYear.find_by!(start_year:)

      indicators_class = [
        Indicator::Count::Pfmps,
        Indicator::Count::Schoolings,
        Indicator::Ratio::AttributiveDecisions,
        Indicator::Ratio::PfmpsPaidPayable,
        Indicator::Ratio::Ribs,
        Indicator::Ratio::StudentsData,
        Indicator::Ratio::PfmpsValidated,
        Indicator::Sum::PfmpsSendable,
        Indicator::Sum::Yearly
      ].map { |indicator_class| indicator_class.new(start_year) }

      %i[sent integrated paid].each do |state|
        indicators_class << Indicator::Count::PaymentRequestStates.new(start_year, state)
      end

      indicators_class << Indicator::Sum::PaymentRequestsStates.new(start_year, :paid)

      @indicators = indicators_class.index_by { |indicator| indicator.title.to_sym }
    end

    def indicators_with_metadata
      Report::HEADERS.map do |title|
        indicator = indicators[title.to_sym]
        next unless indicator

        {
          title: indicator.title,
          tooltip_key: indicator.respond_to?(:tooltip_key) ? indicator.tooltip_key : nil,
          type: indicator.class.superclass.name
        }
      end
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
        initialize_indicators({ BOP: bop }, :bops_data)
      end
    end

    def menj_academies_data
      academies.map do |academy|
        initialize_indicators({ Académie: academy }, :menj_academies_data)
      end
    end

    def establishments_data
      establishments.map do |uai, name, academy, private_code, ministry|
        specific_indicators = {
          UAI: uai,
          "Nom de l'établissement": name,
          Ministère: ministry,
          Académie: academy,
          "Privé/Public": format_private_status(private_code)
        }
        initialize_indicators(specific_indicators, :establishments_data)
      end
    end

    private

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
