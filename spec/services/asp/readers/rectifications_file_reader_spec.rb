# frozen_string_literal: true

require "rails_helper"

describe ASP::Readers::RectificationsFileReader do
  subject(:reader) { described_class.new(io: result, record: record) }

  let(:record) { create(:asp_payment_return) }
  let(:asp_payment_request) { create(:asp_payment_request, :integrated) }

  let(:result) do
    build(
      :asp_rectifications_file,
      payment_state,
      builder_class: ASP::Builder,
      payment_request: asp_payment_request
    )
  end

  shared_examples "a payment request changing to" do |to_state|
    it "marks the associated payment request as #{to_state}" do
      expect { reader.process! }.to change { asp_payment_request.reload.current_state }.from("integrated").to(to_state)
    end

    it "associates the payment request to the payment return" do
      expect { reader.process! }.to change { asp_payment_request.reload.asp_payment_return }.from(nil).to(record)
    end

    it "stores the payment metadata" do
      reader.process!

      expect(asp_payment_request.reload.last_transition.metadata).to have_key "ORDREREVERSEMENT"
    end
  end

  context "when the payment has been successful" do
    let(:payment_state) { :success }

    include_examples "a payment request changing to", "paid"
  end

  context "when the payment failed" do
    let(:payment_state) { :failed }

    include_examples "a payment request changing to", "unpaid"
  end
end
