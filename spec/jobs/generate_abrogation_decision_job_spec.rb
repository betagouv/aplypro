# frozen_string_literal: true

require "rails_helper"

RSpec.describe GenerateAbrogationDecisionJob do
  subject(:job) { described_class.new(schooling) }

  let(:schooling) { create(:schooling, :with_attributive_decision, :closed) }

  describe "#perform" do
    it "generates one abrogation decision per schooling" do
      expect { job.perform_now }.to change { schooling.abrogation_decision.attached? }.from(false).to(true)
    end

    it "bumps the version" do
      expect { job.perform_now }.to change(schooling, :abrogation_decision_version).from(0).to(1)
    end

    it "executes within a transaction" do
      expect(Schooling).to receive(:transaction) # rubocop:disable RSpec/MessageSpies
      job.perform_now
    end

    context "when the attributive decision is missing" do
      let(:schooling) { create(:schooling, :closed) }

      it "raises an error" do
        expect { job.perform_now }.to raise_error GenerateAbrogationDecisionJob::MissingAttributiveDecisionError
      end
    end

    context "when the schooling is open" do
      let(:schooling) { create(:schooling, :with_attributive_decision) }

      it "raises an error" do
        expect { job.perform_now }.to raise_error GenerateAbrogationDecisionJob::MissingSchoolingEndDateError
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
