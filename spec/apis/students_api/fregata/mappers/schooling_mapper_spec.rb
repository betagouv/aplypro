# frozen_string_literal: true

require "rails_helper"

describe StudentsApi::Fregata::Mappers::SchoolingMapper do
  subject(:mapped) { described_class.new.call(data) }

  let(:data) do
    build(
      :fregata_student,
      ine_value: "123456",
      dateEntreeFormation: "2024-05-25",
      dateSortieFormation: "2024-05-30",
      dateSortieEtablissement: "2024-06-01",
      status_code: "2501",
      classe_label: "2NDE JARDINERIE",
      uai: "123456C"
    )
  end

  it "maps the data correctly" do
    expect(mapped).to eq({
                           mef_code: "2712101021",
                           label: "2NDE JARDINERIE",
                           status: :student,
                           uai: "123456C",
                           start_date: "2024-05-25",
                           end_date: "2024-05-30",
                           school_year: 2025
                         })
  end

  describe "status" do
    context "when the student is an apprentice" do
      let(:data) { build(:fregata_student, :apprentice) }

      it "maps it correctly" do
        expect(mapped[:status]).to eq :apprentice
      end
    end

    context "when then student has an unknown type" do
      let(:data) { build(:fregata_student, status_code: "FOOBAR") }

      it "raises Student::Mappers::Errors::SchoolingParsingError" do
        expect { mapped[:status] }.to raise_error Student::Mappers::Errors::SchoolingParsingError
      end
    end
  end

  describe "unwrap order" do
    let(:data) do
      build(
        :fregata_student,
        statutApprenant: { code: "2501" },
        division: {
          code: "2503",
          libelle: "2NDE JARDINERIE"
        }
      )
    end

    it "maps the statutApprenant code" do
      expect(mapped[:status]).to eq :student
    end

    it "still maps the label" do
      expect(mapped[:label]).to eq "2NDE JARDINERIE"
    end
  end
end
