# frozen_string_literal: true

require "rails_helper"

describe PfmpManager do
  subject(:manager) { described_class.new(pfmp) }

  let(:pfmp) { create(:asp_payment_request, :rejected).pfmp }

  describe "#reset_payment_request!" do
    it "creates a new payment request on the pfmp" do
      expect { manager.reset_payment_request! }.to change(pfmp.payment_requests, :count).by(1)
    end
  end
end
