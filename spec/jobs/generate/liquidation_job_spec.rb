# frozen_string_literal: true

require "rails_helper"
require "support/webmock_helpers"

RSpec.describe Generate::LiquidationJob, :student_api do
  subject(:job) { described_class.new(pfmp) }

  let(:pfmp) { create(:pfmp, :validated) }
  let(:student) { pfmp.schooling.student }

  before do
    ActiveJob::Base.queue_adapter = :test

    WebmockHelpers.mock_sygne_token
    WebmockHelpers.mock_sygne_student_endpoint_with(
      student.ine,
      build(:sygne_student_info, ine_value: student.ine).to_json
    )
  end

  describe "#perform" do
    it "generates one liquidation decision per pfmp" do
      expect { job.perform_now }.to change { pfmp.liquidation.attached? }.from(false).to(true)
    end

    it "bumps the version" do
      expect { job.perform_now }.to change(pfmp, :liquidation_version).from(0).to(1)
    end

    it "executes within a transaction" do
      expect(Pfmp).to receive(:transaction) # rubocop:disable RSpec/MessageSpies
      job.perform_now
    end
  end
end
