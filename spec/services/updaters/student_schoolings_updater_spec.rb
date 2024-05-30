# frozen_string_literal: true

require "rails_helper"

describe Updaters::StudentSchoolingsUpdater do
  subject(:updater) { described_class.new(schooling.student) }

  let(:schooling) { create(:schooling) }

  let(:api_double) { instance_double(StudentsApi::Sygne::Api) }
  let(:mapper_double) { instance_double(StudentsApi::Sygne::Mappers::SchoolingMapper) }

  let(:matching_schooling_attributes) do
    {
      uai: schooling.establishment.uai,
      label: schooling.classe.label,
      status: :apprentice,
      school_year: Aplypro::SCHOOL_YEAR,
      start_date: Date.yesterday,
      end_date: Date.current,
      mef_code: schooling.mef.code
    }
  end

  let(:mapped_schooling_attributes) { nil }

  before do
    allow(StudentsApi).to receive(:api_for).and_return api_double

    allow(api_double).to receive_messages(fetch_schooling_data!: ["raw result"], schooling_mapper: mapper_double)
    allow(mapper_double).to receive(:call).and_return(mapped_schooling_attributes)
  end

  it "asks for the schooling information" do
    updater.call

    expect(api_double).to have_received(:fetch_schooling_data!).with(schooling.student.ine)
  end

  context "when there is a matching schooling" do
    let(:mapped_schooling_attributes) { matching_schooling_attributes }

    %i[status start_date end_date].each do |attr|
      it "updates the '#{attr}' attribute" do
        expect { updater.call }.to(change { schooling.reload[attr] })
      end
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
end
