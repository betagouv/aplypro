# frozen_string_literal: true

require "rails_helper"

RSpec.describe Generate::CancellationDecisionJob do
  subject(:job) { described_class.new(schooling) }

  let(:schooling) { create(:schooling, :with_attributive_decision, :closed) }

  describe "#perform" do
    it "generates one abrogation decision per schooling" do
      expect { job.perform_now }.to change { schooling.cancellation_decision.attached? }.from(false).to(true)
    end

    it "executes within a transaction" do
      expect(Schooling).to receive(:transaction) # rubocop:disable RSpec/MessageSpies
      job.perform_now
    end
  end

  describe "callbacks" do
    it "calls the around_perform callback" do
      expect(described_class).to receive(:around_perform_callback).with(job, :generating_attributive_decision) # rubocop:disable RSpec/MessageSpies
      job.perform_now
    end
  end
end
