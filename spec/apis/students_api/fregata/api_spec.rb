# frozen_string_literal: true

require "rails_helper"

describe StudentsApi::Fregata::Api do
  subject(:api) { described_class }

  let(:uai) { create(:establishment, :fregata_provider).uai }

  before do
    mock_fregata_students_with(uai, "")
  end

  describe "fetch_establishment_students!" do
    it "queries the right endpoint with the right parameters" do
      api.fetch_resource(:establishment_students, uai: uai)

      # this will break next year (or whenever we change
      # APLYPRO_SCHOOL_YEAR), which is a great reminder to double-check
      # that everything is updated correctly
      expect(WebMock)
        .to have_requested(:get, api.establishment_students_endpoint(uai: uai))
        .with(query: { rne: uai, anneeScolaireId: 27 })
    end

    context "when the year has changed" do
      before do
        create(:school_year, start_year: 2040)

        mock_fregata_students_with(uai, "")
      end

      it "calculates the proper year" do
        api.fetch_resource(:establishment_students, uai: uai)

        expect(WebMock)
          .to have_requested(:get, api.establishment_students_endpoint(uai: uai))
          .with(query: { rne: uai, anneeScolaireId: 44 })
      end
    end

    context "when the API returns a 401 error" do
      before do
        url = api.establishment_students_endpoint(uai: uai)

        stub_request(:get, url).to_return(status: 401, body: "invalid signature", headers: {})
      end

      it "raises" do
        expect { api.fetch_resource(:establishment_students, uai: uai) }.to raise_error Faraday::UnauthorizedError
      end
    end
  end
end
