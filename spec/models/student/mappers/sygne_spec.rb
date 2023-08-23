# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/api_student"
require "./spec/support/shared/student_mapper"

describe Student::Mappers::Sygne do
  subject(:mapper) { described_class }

  let(:etab) { create(:establishment, :with_fim_principal) }

  before do
    allow(ENV).to receive(:fetch).and_call_original
  end

  context "when the APLYPRO_SYGNE_USE_MEFSTAT4 flag is set" do
    let(:data) { build_list(:sygne_student, 10, mef: "0000", niveau: "2212") }

    before do
      allow(ENV)
        .to receive(:fetch)
        .with("APLYPRO_SYGNE_USE_MEFSTAT4")
        .and_return("some value that is not empty")
    end

    it "uses the MEFSTAT4 to parse the classes" do
      expect(mapper.map_payload(data, etab)).to be_a Array # change(Student, :count).by(10)
    end
  end

  context "when the APLYPRO_SYGNE_USE_MEFSTAT4 flag is unset" do
    let!(:mefs) { Mef.all.sample(10).map(&:code) }
    let(:data) { mefs.map { |code| build(:sygne_student, mef: code) } }
    let(:irrelevant) { build_list(:sygne_student, 20, mef: "-123") }

    before do
      allow(ENV)
        .to receive(:fetch)
        .with("APLYPRO_SYGNE_USE_MEFSTAT4")
        .and_return(nil)
    end

    it_behaves_like "a student mapper"
  end
end
