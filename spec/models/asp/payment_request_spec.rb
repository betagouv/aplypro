# frozen_string_literal: true

require "rails_helper"

RSpec.describe ASP::PaymentRequest do
  subject(:asp_payment_request) { create(:asp_payment_request) }

  describe "associations" do
    it { is_expected.to belong_to(:asp_request).optional }
  end
end
