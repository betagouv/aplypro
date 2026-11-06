# frozen_string_literal: true

require "rails_helper"
require_relative "../../db/mef_seeder"

RSpec.describe MefSeeder do
  def mef_csv_table(*rows)
    headers = %w[MEF MEF_STAT_11 LIBELLE_COURT LIBELLE_LONG MINISTERE]

    CSV::Table.new(rows.map { |row| CSV::Row.new(headers, row) })
  end

  describe ".seed" do
    let!(:school_year) { SchoolYear.find_or_create_by!(start_year: 2030) }
    let(:csv_path) { ["2030_2031.csv"] }
    let(:csv_data) do
      mef_csv_table(
        %w[2402214411 23110022144 1CAP1_CHARCUTERIE CHARCUTERIE-TRAITEUR MENJ],
        %w[2712101021 23211021010 1CAP2A_AGRI AGRICULTURE MASA]
      )
    end

    before do
      allow(CSV).to receive(:read).with(csv_path.first, headers: true).and_return(csv_data)
    end

    it "maps and seeds MEFs idempotently" do
      expect { described_class.seed(csv_path) }.to change(Mef, :count).by(2)

      expect(Mef.find_by!(code: "2402214411", school_year:)).to have_attributes(
        mefstat11: "23110022144",
        short: "1CAP1_CHARCUTERIE",
        label: "CHARCUTERIE-TRAITEUR",
        ministry: "menj"
      )
      expect(Mef.find_by!(code: "2712101021", school_year:).ministry).to eq("masa")

      expect { described_class.seed(csv_path) }.not_to change(Mef, :count)
    end

    it "updates existing MEFs" do
      described_class.seed(csv_path)
      csv_data.first["LIBELLE_LONG"] = "NOUVEAU LIBELLE"

      expect { described_class.seed(csv_path) }
        .to change { Mef.find_by!(code: "2402214411", school_year:).label }
        .from("CHARCUTERIE-TRAITEUR")
        .to("NOUVEAU LIBELLE")
    end

    it "does not insert data when a row cannot be mapped" do
      csv_data[-1]["MINISTERE"] = "UNKNOWN"

      expect { described_class.seed(csv_path) }.to raise_error(ActiveRecord::StatementInvalid)
      expect(Mef.where(school_year:)).to be_empty
    end
  end

  describe "the 2026-2027 MEF file" do
    let(:file_path) { Rails.root.join("data/mefs/2026_2027.csv") }
    let(:school_year) { SchoolYear.find_or_create_by!(start_year: 2026) }

    it "maps and seeds every source row" do # rubocop:disable RSpec/ExampleLength
      data = CSV.read(file_path, headers: true)
      expected = data.map do |row|
        [
          row["MEF"],
          row["MEF_STAT_11"],
          row["LIBELLE_COURT"],
          row["LIBELLE_LONG"],
          row["MINISTERE"].downcase
        ]
      end

      described_class.seed([file_path])

      actual = Mef
               .where(school_year:, code: expected.map(&:first))
               .pluck(:code, :mefstat11, :short, :label, :ministry)

      expect(actual).to match_array(expected)
    end
  end
end
