# frozen_string_literal: true

module Stats
  class Main
    attr_reader :indicators

    def initialize(start_year)
      @school_year = SchoolYear.find_by!(start_year:)

      @indicators = [
        Indicator::AttributiveDecisions,
        Indicator::Ribs,
        Indicator::ValidatedPfmps,
        Indicator::StudentsData,
        Indicator::SendableAmounts,
        Indicator::YearlyAmounts,
        Indicator::Schoolings,
        Indicator::Pfmps
      ].map { |indicator_class| indicator_class.new(start_year) }

      %i[sent integrated paid].each do |state|
        @indicators.push Indicator::PaymentRequestStates.new(start_year, state)
      end

      @indicators.push Indicator::PaymentRequestStateAmounts.new(start_year, :paid)
    end

    def indicators_titles
      indicators.map(&:title)
    end

    def indicators_with_metadata
      indicators.map do |indicator|
        {
          title: indicator.title,
          tooltip_key: indicator.respond_to?(:tooltip_key) ? indicator.tooltip_key : nil
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
      [indicators_titles, indicators.map(&:global_data)]
    end

    def bops_data
      [["BOP", *indicators_titles], *bop_lines]
    end

    def menj_academies_data
      [["Académie", *indicators_titles], *academy_lines]
    end

    def establishments_data
      [establishment_titles, *establishment_lines]
    end

    private

    def format_cell_for_csv(cell)
      cell.is_a?(Float) || cell.nil? ? number_string(cell) : cell
    end

    def bop_lines
      %w[ENPU ENPR MASA MER].map do |bop|
        [bop, *indicators.map { |indicator| indicator.bops_data[bop] }]
      end
    end

    def academy_lines
      academies.map do |academy|
        [academy, *indicators.map { |indicator| indicator.menj_academies_data[academy] }]
      end
    end

    def academies
      Establishment.distinct
                   .order(:academy_label)
                   .reject { |e| Exclusion.establishment_excluded?(e.uai, school_year: @school_year) }
                   .map(&:academy_label).uniq
    end

    def establishment_titles
      ["UAI", "Nom de l'établissement", "Ministère", "Académie", "Privé/Public", *indicators_titles]
    end

    def establishment_lines
      establishments.map do |uai, name, academy, private_code, ministry|
        [uai, name, ministry, academy, format_private_status(private_code), *establishment_indicator_data(uai)]
      end
    end

    def establishments
      Establishment.distinct
                   .order(:uai)
                   .reject { |e| Exclusion.establishment_excluded?(e.uai, school_year: @school_year) }
                   .map { |e| [e.uai, e.name, e.academy_label, e.private_contract_type_code, e.ministry] }
    end

    def format_private_status(private_code)
      private_code == "99" ? "Public" : "Privé"
    end

    def establishment_indicator_data(uai)
      indicators.map { |indicator| indicator.establishments_data[uai] }
    end

    def number_string(ratio)
      return 0 if ratio.nil? || ratio.nan?
      return "Infini" if ratio.infinite?

      ratio.to_s.gsub(".", ",")
    end
  end
end
