# frozen_string_literal: true

# spec/lib/wage_seeder_spec.rb
require "rails_helper"
require_relative "../../db/wage_seeder"

# rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
RSpec.describe WageSeeder do
  describe ".seed" do
    let!(:school_year) { SchoolYear.create!(start_year: 2022) }
    let(:csv_path) { ["2022_2023.csv"] }

    context "when seeding wages" do
      let(:csv_data) do
        [
          CSV::Row.new(
            ["MEF", "MEF_STAT_11", "MEF_STAT_4", "DISPOSITIF_FORMATION", "LIBELLE_LONG", "BOP", "FORFAIT JOURNALIER",
             "PLAFOND MAX"],
            ["2402214411", "23110022144", "2311", "240", "1CAP1  CHARCUTERIE-TRAITEUR", "MENJ", "15", "525"]
          ),
          CSV::Row.new(
            ["MEF", "MEF_STAT_11", "MEF_STAT_4", "DISPOSITIF_FORMATION", "LIBELLE_LONG", "BOP", "FORFAIT JOURNALIER",
             "PLAFOND MAX"],
            ["2402214511", "23110022145", "2311", "240", "1CAP1  CHOCOLATERIE-CONFISERIE", "MENJ", "15", "525"]
          )
        ]
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
        [
          CSV::Row.new(
            ["MEF", "MEF_STAT_11", "MEF_STAT_4", "DISPOSITIF_FORMATION", "LIBELLE_LONG", "BOP", "FORFAIT JOURNALIER",
             "PLAFOND MAX"],
            ["2402214411", "23110022144", "2311", "240", "1CAP1  CHARCUTERIE-TRAITEUR", "MENJ", "15", "525"]
          )
        ]
      end

      let(:updated_csv_data) do
        [
          CSV::Row.new(
            ["MEF", "MEF_STAT_11", "MEF_STAT_4", "DISPOSITIF_FORMATION", "LIBELLE_LONG", "BOP", "FORFAIT JOURNALIER",
             "PLAFOND MAX"],
            ["2402214411", "23110022144", "2311", "240", "1CAP1  CHARCUTERIE-TRAITEUR", "MENJ", "15", "525"]
          ),
          CSV::Row.new(
            ["MEF", "MEF_STAT_11", "MEF_STAT_4", "DISPOSITIF_FORMATION", "LIBELLE_LONG", "BOP", "FORFAIT JOURNALIER",
             "PLAFOND MAX"],
            ["2402413211", "23110024132", "2311", "240", "1CAP1  FLEURISTE DE MODE", "MENJ", "15", "525"]
          )
        ]
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
  end
end
# rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
