# frozen_string_literal: true

module Academic
  class EstablishmentsReportExtractor
    def initialize(report, academy_code, school_year)
      @report = report
      @academy_code = academy_code
      @school_year = school_year
    end

    def extract_establishments_data
      raw_data = fetch_raw_data
      academy_rows = filter_by_academy(raw_data)
      enrich_with_establishment_details(academy_rows)
    end

    def extract_single_establishment_data(establishment_uai)
      all_data = extract_establishments_data
      all_data[establishment_uai]
    end

    private

    def fetch_raw_data
      Reports::BaseExtractor.new(@report).extract(:establishments_data)
    end

    def filter_by_academy(data)
      headers = data[0]
      rows = data[1..]

      academy_idx = headers.index("academy")
      academy_label = Establishment::ACADEMY_LABELS[@academy_code]
      rows.select { |row| row[academy_idx] == academy_label }
    end

    def extract_column_indexes(headers)
      {
        uai: headers.index("uai"),
        academy: headers.index("academy"),
        schoolings_count: headers.index("schoolings_count"),
        pfmps_validated_sum: headers.index("pfmps_validated_sum"),
        payment_requests_paid_sum: headers.index("payment_requests_paid_sum")
      }
    end

    def enrich_with_establishment_details(academy_rows)
      return {} if academy_rows.empty?

      headers = fetch_raw_data[0]
      indexes = extract_column_indexes(headers)

      uais = extract_uais_from_rows(academy_rows, indexes[:uai])
      establishments = fetch_establishments_by_uai(uais)

      build_data_hash(academy_rows, establishments, indexes)
    end

    def extract_uais_from_rows(academy_rows, uai_idx)
      academy_rows.pluck(uai_idx)
    end

    def fetch_establishments_by_uai(uais)
      Establishment
        .select(:id, :uai, :name, :address_line1, :address_line2, :city, :postal_code, :academy_code)
        .where(uai: uais)
        .index_by(&:uai)
    end

    def build_data_hash(academy_rows, establishments, indexes)
      data = {}

      academy_rows.each do |row|
        uai = row[indexes[:uai]]
        establishment = establishments[uai]
        next unless establishment

        data[uai] = build_establishment_entry(establishment, row, indexes)
      end

      data.sort_by { |_uai, etab_data| -etab_data[:paid_amount] }.to_h
    end

    def build_establishment_entry(establishment, row, indexes)
      establishment.attributes.symbolize_keys.merge(
        schooling_count: row[indexes[:schoolings_count]] || 0,
        payable_amount: row[indexes[:pfmps_validated_sum]] || 0,
        paid_amount: row[indexes[:payment_requests_paid_sum]] || 0
      )
    end
  end
end
