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
      pfmp = create(:pfmp, :completed)
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
    describe "transition to rectified" do
      let(:pfmp) { create(:pfmp, :validated) }
      let(:payment_request) { instance_double(ASP::PaymentRequest) }

      before do
        allow(pfmp).to receive(:latest_payment_request).and_return(payment_request)
      end

      context "when the latest payment request is paid" do
        before do
          allow(payment_request).to receive(:in_state?).with(:paid).and_return(true)
        end

        it "allows transition to rectified" do
          expect { pfmp.state_machine.transition_to!(:rectified) }.to change(pfmp.state_machine, :current_state)
            .from("validated")
            .to("rectified")
        end
      end

      context "when the latest payment request is not paid" do
        before do
          allow(payment_request).to receive(:in_state?).with(:paid).and_return(false)
        end

        it "does not allow transition to rectified" do
          expect { pfmp.state_machine.transition_to!(:rectified) }.to raise_error(Statesman::GuardFailedError)
        end
      end
    end
  end
end
