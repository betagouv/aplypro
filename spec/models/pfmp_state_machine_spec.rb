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
      pfmp = create(:pfmp, :validated)
      expect { pfmp.state_machine.transition_to!(:rectified) }.to change(pfmp.state_machine, :current_state)
        .from("validated")
        .to("rectified")
    end
  end
end
