# frozen_string_literal: true

require "rails_helper"
require "support/webmock_helpers"

RSpec.describe Generate::CancellationDecisionJob, :student_api do
  subject(:job) { described_class.new(schooling) }

  let(:schooling) { create(:schooling, :with_attributive_decision, :closed) }
  let(:student) { schooling.student }

  before do
    ActiveJob::Base.queue_adapter = :test

    WebmockHelpers.mock_sygne_token
    WebmockHelpers.mock_sygne_student_endpoint_with(
      student.ine,
      build(:sygne_student_info, ine_value: student.ine).to_json
    )
  end

  describe "#perform" do
    it "generates one abrogation decision per schooling" do
      expect { job.perform_now }.to change { schooling.cancellation_decision.attached? }.from(false).to(true)
    end

    it "executes within a transaction" do
      expect(Schooling).to receive(:transaction) # rubocop:disable RSpec/MessageSpies
      job.perform_now
    end

    context "when the confirmed director is missing" do
      before do
        schooling.establishment.update!(confirmed_director: nil)
      end

      it "raises an error" do
        expect { job.perform_now }.to raise_error Generator::MissingConfirmedDirectorError
      end
    end
  end

  describe "callbacks" do
    it "calls the around_perform callback" do
      expect(described_class).to receive(:around_perform_callback).with(job, :generating_attributive_decision) # rubocop:disable RSpec/MessageSpies
      job.perform_now
    end
  end
end
