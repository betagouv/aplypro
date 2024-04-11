# frozen_string_literal: true

require "rails_helper"

describe ASP::Readers::PaymentsFileReader do
  subject(:reader) { described_class.new(result, record) }

  let(:record) { create(:asp_payment_return) }
  let(:asp_payment_request) { create(:asp_payment_request, :integrated) }

  let(:result) do
    build(
      :asp_payment_file,
      payment_state,
      builder_class: ASP::Builder,
      payment_request: asp_payment_request
    )
  end

  context "when the payment has been successful" do
    let(:payment_state) { :success }

    it "marks the associated payment request as paid" do
      expect { reader.process! }.to change { asp_payment_request.reload.current_state }.from("integrated").to("paid")
    end

    it "associates the payment request with the file" do
      expect { reader.process! }.to change { asp_payment_request.reload.asp_payment_return }.from(nil).to(record)
    end
  end

  context "when the payment failed" do
    let(:payment_state) { :failed }

    it "marks the associated payment request as unpaid" do
      expect { reader.process! }.to change { asp_payment_request.reload.current_state }.from("integrated").to("unpaid")
    end

    it "associates the payment request with the file" do
      expect { reader.process! }.to change { asp_payment_request.reload.asp_payment_return }.from(nil).to(record)
    end
  end
end
