# frozen_string_literal: true

require "rails_helper"

describe StudentsApi::Fregata::Api do
  subject(:api) { described_class }

  let(:uai) { create(:establishment, :fregata_provider).uai }
  let(:student) { create(:schooling).student }

  before do
    mock_fregata_students_with(uai, "")
  end

  describe "find_student_in_payload" do
    let(:ine) { "123456789AB" }
    let(:fregata_student) { build(:fregata_student, ine_value: ine).to_h }
    let(:en_student) { build(:fregata_student, :national_education, ine_value: ine).to_h }

    before do
      allow_any_instance_of(StudentsApi::Fregata::Mappers::StudentMapper).to receive(:call) do |_, entry| # rubocop:disable RSpec/AnyInstance
        { ine: entry.dig("apprenant", "ine") }
      end
    end

    it "filters out students with estEN set to true" do
      payload = [en_student, fregata_student]

      result = api.send(:find_student_in_payload, payload, ine)
      expect(result).to eq(fregata_student)
    end
  end

  describe "student_endpoint" do
    let(:uai) { student.current_schooling.establishment.uai }

    context "when uai and start_year are provided" do
      it "returns the corresponding establishment_students_endpoint" do
        endpoint = api.student_endpoint(uai: uai, start_year: student.current_schooling.classe.school_year.start_year)
        expect(endpoint).to eq api.establishment_students_endpoint(
          uai: uai, start_year: student.current_schooling.classe.school_year.start_year
        )
      end
    end

    context "when start_year is not provided" do
      it "raises ActiveRecord::RecordNotFound" do
        expect { api.student_endpoint(uai: uai) }
          .to raise_error(KeyError)
      end
    end
  end

  describe "fetch_establishment_students!" do
    it "queries the right endpoint with the right parameters" do
      api.fetch_resource(:establishment_students, uai: uai, start_year: SchoolYear.current.start_year)

      expect(WebMock)
        .to have_requested(:get,
                           api.establishment_students_endpoint(
                             uai: uai,
                             start_year: student.current_schooling.classe.school_year.start_year
                           ))
        .with(query: { rne: uai,
                       anneeScolaireId: SchoolYear.current.start_year - StudentsApi::Fregata::Api::YEAR_OFFSET })
    end

    context "when the year has changed" do
      before do
        create(:school_year, start_year: 2040)

        mock_fregata_students_with(uai, "")
      end

      it "calculates the proper year" do
        api.fetch_resource(:establishment_students, uai: uai,
                                                    start_year: SchoolYear.current.start_year)

        expect(WebMock)
          .to have_requested(:get,
                             api.establishment_students_endpoint(uai: uai,
                                                                 start_year: SchoolYear.current.start_year))
          .with(query: { rne: uai, anneeScolaireId: 44 })
      end
    end

    context "when the API returns a 401 error" do
      before do
        url = api.establishment_students_endpoint(uai: uai,
                                                  start_year: student.current_schooling.classe.school_year.start_year)

        stub_request(:get, url).to_return(status: 401, body: "invalid signature", headers: {})
      end

      it "raises" do
        expect do
          api.fetch_resource(:establishment_students,
                             uai: uai,
                             start_year: student.current_schooling.classe.school_year.start_year)
        end.to raise_error Faraday::UnauthorizedError
      end
    end
  end
end
