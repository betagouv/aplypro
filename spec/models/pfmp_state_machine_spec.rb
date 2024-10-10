# frozen_string_literal: true

require "rails_helper"

describe PfmpStateMachine do
  subject(:state_machine) { pfmp.state_machine }

  let(:pfmp) { create(:pfmp) }

  it "has an initial state of pending" do
    expect(state_machine.current_state).to eq("pending")
  end

  describe "transitions" do
    it "can transition from pending to completed" do
      expect { pfmp.update(day_count: 5) }.to change(state_machine, :current_state)
        .from("pending")
        .to("completed")
    end

    it "can transition from completed to validated" do
      pfmp = create(:pfmp, :can_be_validated)
      expect { pfmp.state_machine.transition_to!(:validated) }.to change(pfmp.state_machine, :current_state)
        .from("completed")
        .to("validated")
    end

    it "can transition from completed to pending" do
      pfmp = create(:pfmp, :completed)
      expect { pfmp.state_machine.transition_to!(:pending) }.to change(pfmp.state_machine, :current_state)
        .from("completed")
        .to("pending")
    end

    it "can transition from validated to rectified" do
      pfmp = create(:asp_payment_request, :paid).pfmp
      expect { pfmp.state_machine.transition_to!(:rectified) }.to change(pfmp.state_machine, :current_state)
        .from("validated")
        .to("rectified")
    end
  end

  describe "guards" do
    let(:payment_request) { pfmp.latest_payment_request }

    describe "transition to validated" do
      context "when the latest payment request is validable" do
        let(:pfmp) { create(:pfmp, :can_be_validated) }

        it "allows transition to validated" do
          expect { pfmp.state_machine.transition_to!(:validated) }.to change(pfmp.state_machine, :current_state)
            .from("completed")
            .to("validated")
        end
      end

      context "when the latest payment request is not validable" do
        let(:pfmp) { create(:pfmp, :completed) }

        it "does not allow transition to validated" do
          expect { pfmp.state_machine.transition_to!(:validated) }.to raise_error(Statesman::GuardFailedError)
        end
      end
    end

    describe "transition to rectified" do
      context "when the latest payment request is paid" do
        let(:pfmp) { create(:asp_payment_request, :paid).pfmp }

        it "allows transition to rectified" do
          expect { pfmp.state_machine.transition_to!(:rectified) }.to change(pfmp.state_machine, :current_state)
            .from("validated")
            .to("rectified")
        end
      end

      context "when the latest payment request is not paid" do
        let(:pfmp) { create(:asp_payment_request, :unpaid).pfmp }

        it "does not allow transition to rectified" do
          expect { pfmp.state_machine.transition_to!(:rectified) }.to raise_error(Statesman::GuardFailedError)
        end
      end
    end
  end

  describe "after_transition hooks" do
    describe "transition to rectified" do
      let(:pfmp) { create(:asp_payment_request, :paid).pfmp }

      it "recalculates amounts and creates a new payment request and attempts to mark it as ready" do # rubocop:disable RSpec/MultipleExpectations
        expect do
          pfmp.state_machine.transition_to!(:rectified)
        end.to change { pfmp.payment_requests.count }.by(1)

        expect(pfmp.current_state).to eq("rectified")
        expect(pfmp.payment_requests.last.reload.current_state).to eq("ready")
      end
    end
  end
end
