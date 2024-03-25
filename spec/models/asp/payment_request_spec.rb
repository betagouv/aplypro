# frozen_string_literal: true

require "rails_helper"

RSpec.describe ASP::PaymentRequest do
  subject(:asp_payment_request) { create(:asp_payment_request) }

  describe "associations" do
    it { is_expected.to belong_to(:asp_request).optional }
  end

  describe "factory" do
    it "does not create extra payment requests" do
      expect { create(:asp_payment_request) }.to change(described_class, :count).by(1)
    end
  end
end
