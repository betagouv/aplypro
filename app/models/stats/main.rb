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
      data.map do |row|
        row.map do |cell|
          if cell.is_a?(Float) || cell.nil?
            number_string(cell)
          else
            cell
          end
        end.join("\t")
      end.join("\n")
    end

    def global_data
      lines = indicators.map(&:global_data)

      [indicators_titles, lines]
    end

    def bops_data
      titles = ["BOP", *indicators_titles]
      bops = %w[ENPU ENPR MASA MER]

      bop_lines = bops.map do |bop|
        [
          bop,
          *indicators.map { |indicator| indicator.bops_data[bop] }
        ]
      end

      [titles, *bop_lines]
    end

    def menj_academies_data
      titles = ["Académie", *indicators_titles]
      academies = Establishment.distinct
                               .order(:academy_label)
                               .reject { |e| Exclusion.establishment_excluded?(e.uai, school_year: @school_year) }
                               .map(&:academy_label).uniq

      academy_lines = academies.map do |academy|
        [
          academy,
          *indicators.map { |indicator| indicator.menj_academies_data[academy] }
        ]
      end

      [titles, *academy_lines]
    end

    def establishments_data # rubocop:disable Metrics/AbcSize
      titles = ["UAI", "Nom de l'établissement", "Ministère", "Académie", "Privé/Public", *indicators_titles]
      establishments = Establishment
                       .distinct
                       .order(:uai)
                       .reject { |e| Exclusion.establishment_excluded?(e.uai, school_year: @school_year) }
                       .map { |e| [e.uai, e.name, e.academy_label, e.private_contract_type_code, e.ministry] }

      establishment_lines = establishments.map do |uai, name, academy, private_code, ministry|
        is_private = private_code == "99" ? "Public" : "Privé"
        [
          uai,
          name,
          ministry,
          academy,
          is_private,
          *indicators.map { |indicator| indicator.establishments_data[uai] }
        ]
      end

      [titles, *establishment_lines]
    end

    private

    def number_string(ratio)
      return 0 if ratio.nil? || ratio.nan?
      return "Infini" if ratio.infinite?

      ratio.to_s.gsub(".", ",")
    end
  end
end
