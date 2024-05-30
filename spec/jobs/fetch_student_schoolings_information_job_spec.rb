# frozen_string_literal: true

require "rails_helper"

RSpec.describe FetchStudentSchoolingsInformationJob do
  let(:student) { create(:student) }
  let(:updater_double) { class_double(Updaters::StudentSchoolingsUpdater) }

  before do
    stub_const("Updaters::StudentSchoolingsUpdater", updater_double)

    allow(updater_double).to receive(:call)
  end

  it "delegates to the updater" do
    described_class.perform_now(student)

    expect(updater_double).to have_received(:call).with(student)
  end
end
