# frozen_string_literal: true

require "rails_helper"
require "support/webmock_helpers"

RSpec.describe GenerateAttributiveDecisionJob do
  subject(:job) { described_class.new(schooling) }

  let(:schooling) { create(:schooling) }
  let(:student) { schooling.student }

  before do
    ActiveJob::Base.queue_adapter = :test

    WebmockHelpers.mock_sygne_token_with
    WebmockHelpers.mock_sygne_student_endpoint_with(student.ine, build(:sygne_student, ine_value: student.ine).to_json)
  end

  # NOTE: there's the much nicer
  #
  #   expect { job.perform_now }
  #     .to have_enqueued_job(FetchStudentAddressJob).with(schooling)
  #
  # but we can't use it because we request the address *synchronously*
  # hence we use `perform_now` which skips the underlying job queue
  # and prevents queue-based matchers like `have_enqueued_job`. Use
  # the WebMock requests instead.
  context "when the student does not have an address" do
    it "fetches it beforehand" do
      job.perform_now

      expect(a_request(:get, /#{ENV.fetch('APLYPRO_SYGNE_URL')}/)).to have_been_made
    end
  end

  context "when the student already has an address" do
    before { student.update!(address_line1: "some address") }

    it "does not call the api" do
      job.perform_now

      expect(a_request(:get, /#{ENV.fetch('APLYPRO_SYGNE_URL')}/)).not_to have_been_made
    end
  end

  it "generates one attributive decision per student" do
    expect { job.perform_now }.to change { schooling.attributive_decision.attached? }.from(false).to(true)
  end

  it "toggles the generating attributive decision boolean" do
    schooling.update!(generating_attributive_decision: true)

    expect { job.perform_now }.to change(schooling, :generating_attributive_decision).to(false)
  end
end
