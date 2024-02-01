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
  end
end
