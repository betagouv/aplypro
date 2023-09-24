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

    context "when the process! method is called" do
      it "moves to processed" do
        expect { payment.process! }.to change(payment, :current_state).from("pending").to("processing")
      end
    end

    context "when the complete! method is called" do
      before do
        payment.process!
      end

      it "moves to successful" do
        expect { payment.complete! }.to change(payment, :current_state).from("processing").to("success")
      end
    end
  end
end
