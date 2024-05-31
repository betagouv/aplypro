# frozen_string_literal: true

require "rails_helper"

RSpec.describe FetchStudentsJob do
  include ActiveJob::TestHelper

  let(:establishment) { create(:establishment, :sygne_provider) }
  let(:api_double) { class_double(StudentsApi::Sygne::Api) }
  let(:mapper_double) { instance_double(Student::Mappers::Sygne) }

  before do
    allow(StudentsApi).to receive(:api_for).with("sygne").and_return(api_double)

    allow(api_double).to receive(:fetch_resource).with(:establishment_students, uai: establishment.uai)
    allow(api_double)
      .to receive(:mapper)
      .and_return(class_double(Student::Mappers::Sygne, new: mapper_double))

    allow(mapper_double).to receive(:parse!)
  end

  it "calls the matchingStudentsApi proxy" do
    described_class.perform_now(establishment)

    expect(StudentsApi).to have_received(:api_for).with("sygne")
  end

  it "maps and parse the results" do
    described_class.perform_now(establishment)

    expect(mapper_double).to have_received(:parse!)
  end

  context "when the underlying API fails" do
    before do
      allow(api_double).to receive(:fetch_resource).and_raise(Faraday::UnauthorizedError)
    end

    it "rescues and retry" do
      perform_enqueued_jobs do
        described_class.perform_now(establishment)
      rescue Faraday::UnauthorizedError # rubocop:disable Lint/SuppressedException
      end

      expect(api_double).to have_received(:fetch_resource).exactly(10).times
    end
  end
end
