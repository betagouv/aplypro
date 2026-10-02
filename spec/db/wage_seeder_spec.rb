# frozen_string_literal: true

# spec/lib/wage_seeder_spec.rb
require "rails_helper"
require_relative "../../db/wage_seeder"

# rubocop:disable RSpec/ExampleLength
RSpec.describe WageSeeder do
  def wage_csv_table(*rows)
    headers = [
      "MEF", "MEF_STAT_11", "MEF_STAT_4", "DISPOSITIF_FORMATION",
      "LIBELLE_LONG", "BOP", "FORFAIT JOURNALIER", "PLAFOND MAX"
    ]

    CSV::Table.new(rows.map { |row| CSV::Row.new(headers, row) })
  end

  describe ".seed" do
    let!(:school_year) { SchoolYear.create!(start_year: 2022) }
    let(:csv_path) { ["2022_2023.csv"] }

    context "when seeding wages" do
      let(:csv_data) do
        wage_csv_table(
          ["2402214411", "23110022144", "2311", "240", "1CAP1  CHARCUTERIE-TRAITEUR", "MENJ", "15", "525"],
          ["2402214511", "23110022145", "2311", "240", "1CAP1  CHOCOLATERIE-CONFISERIE", "MENJ", "15", "525"]
        )
      end

      before do
        allow(CSV).to receive(:read).with(csv_path.first, headers: true).and_return(csv_data)
      end

      it "is idempotent" do
        described_class.seed(csv_path)

        wage = Wage.last
        expect(wage).to have_attributes(
          mefstat4: "2311",
          ministry: "menj",
          daily_rate: 15,
          yearly_cap: 525,
          mef_codes: contain_exactly("2402214411", "2402214511"),
          school_year: school_year
        )

        expect { described_class.seed(csv_path) }.not_to change(Wage, :count)
        expect(Wage.last.attributes).to eq(wage.attributes)
      end
    end

    context "when adding new data" do
      let(:csv_data) do
        wage_csv_table(
          ["2402214411", "23110022144", "2311", "240", "1CAP1  CHARCUTERIE-TRAITEUR", "MENJ", "15", "525"]
        )
      end

      let(:updated_csv_data) do
        wage_csv_table(
          ["2402214411", "23110022144", "2311", "240", "1CAP1  CHARCUTERIE-TRAITEUR", "MENJ", "15", "525"],
          ["2402413211", "23110024132", "2311", "240", "1CAP1  FLEURISTE DE MODE", "MENJ", "15", "525"]
        )
      end

      before do
        allow(CSV).to receive(:read).with(csv_path.first, headers: true).and_return(csv_data)
      end

      it "handles updates correctly" do
        described_class.seed(csv_path)
        expect(Wage.last.mef_codes).to contain_exactly("2402214411")

        allow(CSV).to receive(:read).with(csv_path.first, headers: true).and_return(updated_csv_data)
        expect { described_class.seed(csv_path) }.not_to change(Wage, :count)
        expect(Wage.last.mef_codes).to contain_exactly("2402214411", "2402413211")
      end
    end

    context "with malformed CSV data" do
      let(:headers) do
        ["MEF", "MEF_STAT_4", "BOP", "FORFAIT JOURNALIER", "PLAFOND MAX"]
      end
      let(:values) { %w[2402214411 2311 MENJ 15 525] }
      let(:csv_data) { CSV::Table.new([CSV::Row.new(headers, values)]) }

      before do
        allow(CSV).to receive(:read).with(csv_path.first, headers: true).and_return(csv_data)
      end

      it "rejects missing required headers before inserting wages" do
        malformed_row = CSV::Row.new(
          ["MEF", "MEF_STAT_4", "BOP", "PLAFOND MAX"],
          %w[2402214411 2311 MENJ 525]
        )
        malformed_data = CSV::Table.new([malformed_row])
        allow(CSV).to receive(:read).with(csv_path.first, headers: true).and_return(malformed_data)
        wage_count = Wage.count

        expect { described_class.seed(csv_path) }
          .to raise_error(described_class::InvalidCsvError, /missing required headers: FORFAIT JOURNALIER/)
        expect(Wage.count).to eq(wage_count)
      end

      it "rejects non-positive and non-integer amounts before inserting wages" do
        valid_values = { "FORFAIT JOURNALIER" => "15", "PLAFOND MAX" => "525" }

        valid_values.each_key do |header|
          %w[0 -1 15.5 invalid].each do |invalid_value|
            csv_data.first[header] = invalid_value
            wage_count = Wage.count

            expect { described_class.seed(csv_path) }
              .to raise_error(described_class::InvalidCsvError, /line 2 has an invalid #{header}/)
            expect(Wage.count).to eq(wage_count)

            csv_data.first[header] = valid_values.fetch(header)
          end
        end
      end

      it "rejects rows without MEF identifiers before inserting wages" do
        %w[MEF MEF_STAT_4].each do |header|
          original_value = csv_data.first[header]
          csv_data.first[header] = ""
          wage_count = Wage.count

          expect { described_class.seed(csv_path) }
            .to raise_error(described_class::InvalidCsvError, /line 2 has no #{header}/)
          expect(Wage.count).to eq(wage_count)

          csv_data.first[header] = original_value
        end
      end

      it "rejects unknown ministries before inserting wages" do
        csv_data.first["BOP"] = "UNKNOWN"
        wage_count = Wage.count

        expect { described_class.seed(csv_path) }
          .to raise_error(described_class::InvalidCsvError, /line 2 has an unknown BOP: UNKNOWN/)
        expect(Wage.count).to eq(wage_count)
      end
    end

    context "with the 2026-2027 wage file" do
      let(:file_path) { Rails.root.join("data/wages/2026_2027.csv") }
      let!(:new_school_year) { SchoolYear.find_or_create_by!(start_year: 2026) }

      it "validates and seeds every wage" do
        described_class.seed([file_path])

        wages = Wage.where(school_year: new_school_year)

        expect(wages).not_to be_empty
        expect(wages.pluck(:daily_rate)).to all(be_positive)
        expect(wages.pluck(:yearly_cap)).to all(be_positive)
        expect(wages.flat_map(&:mef_codes).uniq.size).to eq(1471)
      end
    end
  end
end
# rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
