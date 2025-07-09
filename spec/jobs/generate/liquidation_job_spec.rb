# frozen_string_literal: true

require "rails_helper"
require "support/webmock_helpers"
require "hexapdf"

RSpec.describe Generate::LiquidationJob, :student_api do
  subject(:job) { described_class.new(schooling) }

  let(:schooling) { create(:schooling) }
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
    context "when the schooling has no pfmp" do
      it "does not generate a liquidation for the schooling" do
        expect { job.perform_now }.not_to change { schooling.liquidation.attached? }.from(false)
      end
    end

    context "when the schooling has pfmp" do
      let(:pfmps) { create_list(:pfmp, 3, :validated, schooling: schooling) }

      before { schooling.update(pfmps: pfmps) }

      it "generates a liquidation for the schooling" do
        expect { job.perform_now }.to change { schooling.liquidation.attached? }.from(false).to(true)
      end

      it "generates a number of pages equal to the number of PFMPs" do
        job.perform_now

        tempfile = Tempfile.new("état-liquidatif.pdf")
        tempfile.binmode
        tempfile.write(schooling.liquidation.download)

        expect(HexaPDF::Document.open(tempfile.path).pages.count).to eq(pfmps.size)
      end

      it "bumps the version" do
        expect { job.perform_now }.to change(schooling, :liquidation_version).from(0).to(1)
      end

      it "executes within a transaction" do
        expect(Schooling).to receive(:transaction) # rubocop:disable RSpec/MessageSpies
        job.perform_now
      end
    end
  end
end
