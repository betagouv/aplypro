# frozen_string_literal: true

require "rails_helper"

RSpec.describe FetchStudentsJob do
  include ActiveJob::TestHelper

  let(:establishment) { create(:establishment, :sygne_provider) }

  before do
    allow(StudentsApi).to receive(:fetch_students!)
  end

  it "calls the matchingStudentsApi proxy" do
    described_class.perform_now(establishment)

    expect(StudentsApi).to have_received(:fetch_students!).with("sygne", establishment.uai)
  end

  context "when the underlying API fails" do
    before do
      allow(StudentsApi).to receive(:fetch_students!).and_raise(Faraday::UnauthorizedError)
    end

    it "rescues and retry" do
      perform_enqueued_jobs do
        described_class.perform_now(establishment)
      rescue Faraday::UnauthorizedError # rubocop:disable Lint/SuppressedException
      end

      expect(StudentsApi).to have_received(:fetch_students!).exactly(10).times
    end
  end
end
