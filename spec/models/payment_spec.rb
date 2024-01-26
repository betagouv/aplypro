# frozen_string_literal: true

require "rails_helper"

RSpec.describe Payment do
  subject(:payment) { create(:payment) }

  it { is_expected.to belong_to(:pfmp) }
  it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }

  describe "transitions" do
    it "starts in created state" do
      expect(payment.state_machine).to be_in_state "pending"
    end

    describe "moving to ready" do
      context "when the student doesn't have a RIB information" do
        before { payment.student.rib&.destroy }

        it "blocks the transition" do
          expect { payment.mark_ready! }.to raise_error Statesman::GuardFailedError
        end
      end
    end
  end
end
