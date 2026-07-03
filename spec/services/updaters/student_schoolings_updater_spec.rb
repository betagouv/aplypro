# frozen_string_literal: true

require "rails_helper"

describe Updaters::StudentSchoolingsUpdater do
  subject(:updater) { described_class.new(schooling.student) }

  let(:schooling) { create(:schooling) }

  let(:api_double) { class_double(StudentsApi::Sygne::Api) }
  let(:mapper_double) { instance_double(StudentsApi::Sygne::Mappers::SchoolingMapper) }

  let(:matching_schooling_attributes) do
    {
      uai: schooling.establishment.uai,
      label: schooling.classe.label,
      status: :apprentice,
      school_year: SchoolYear.current.start_year,
      start_date: Date.yesterday,
      end_date: Date.current,
      mef_code: schooling.mef.code
    }
  end

  let(:mapped_schooling_attributes) { nil }

  before do
    allow(StudentsApi).to receive(:api_for).and_return api_double

    allow(api_double)
      .to receive(:fetch_resource)
      .with(:student_schoolings,
            ine: schooling.student.ine,
            uai: schooling.establishment.uai,
            start_year: schooling.classe.school_year.start_year)
      .and_return(["raw result"])

    allow(api_double)
      .to receive(:schooling_mapper)
      .and_return(class_double(StudentsApi::Sygne::Mappers::SchoolingMapper, new: mapper_double))

    allow(mapper_double).to receive(:call).and_return(mapped_schooling_attributes)
  end

  it "asks for the schooling information" do
    updater.call

    expect(api_double).to have_received(:fetch_resource).with(
      :student_schoolings, ine: schooling.student.ine,
                           uai: schooling.establishment.uai,
                           start_year: schooling.classe.school_year.start_year
    )
  end

  context "when there is a matching schooling" do
    let(:mapped_schooling_attributes) { matching_schooling_attributes }

    %i[status start_date end_date].each do |attr|
      it "updates the '#{attr}' attribute" do
        expect { updater.call }.to(change { schooling.reload[attr] })
      end
    end
  end

  context "when all necessary attributes are not present" do
    let(:matching_schooling_attributes) do
      {
        status: :apprentice,
        start_date: Date.yesterday,
        end_date: Date.current
      }
    end

    it "does not account for it" do
      expect { updater.call }.not_to(change { schooling.reload.attributes })
    end
  end

  context "when a schooling is from an unknown establishment" do
    let(:mapped_schooling_attributes) { matching_schooling_attributes.update(uai: "unknown") }

    it "does not account for it" do
      expect { updater.call }.not_to(change { schooling.reload.attributes })
    end
  end

  context "when a schooling is from an unknown class" do
    let(:mapped_schooling_attributes) { matching_schooling_attributes.update(label: "unknown") }

    it "does not account for it" do
      expect { updater.call }.not_to(change { schooling.reload.attributes })
    end
  end

  context "when a schooling is for a class that exists but with a different MEF" do
    let(:mapped_schooling_attributes) { matching_schooling_attributes.update(mef_code: "unknown") }

    it "does not account for it" do
      expect { updater.call }.not_to(change { schooling.reload.attributes })
    end
  end

  context "with a real FREGATA-backed schooling" do
    subject(:updater) { described_class.new(schooling.student) }

    let(:schooling) do
      establishment = create(:establishment, :fregata_provider)
      classe = create(:classe, establishment: establishment, label: "2NDE JARDINERIE")

      create(:schooling, classe: classe, status: :student)
    end

    before do
      allow(StudentsApi).to receive(:api_for).and_call_original

      classe = schooling.classe
      fregata_year = classe.school_year.start_year - StudentsApi::Fregata::Api::YEAR_OFFSET

      mock_fregata_students_with(
        classe.establishment.uai,
        [
          build(
            :fregata_student,
            ine_value: schooling.student.ine,
            status_code: "2503",
            division: { "libelle" => classe.label },
            sectionReference: { "codeMef" => "#{classe.mef.code}0", "anneeScolaireId" => fregata_year }
          ).to_h,
          build(:fregata_student, status_code: "2503").to_h
        ].to_json
      )
    end

    it "finds the matching classe from the FREGATA payload and updates the schooling" do
      expect { updater.call }.to change { schooling.reload.status }.from("student").to("apprentice")
    end
  end
end
