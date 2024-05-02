# frozen_string_literal: true

require "rails_helper"

describe ASP::PaymentRequestDecorator do
  subject(:decorator) { ActiveDecorator::Decorator.instance.decorate(payment_request) }

  let(:payment_request) { create(:asp_payment_request) }

  describe ".rejection_reason" do
    subject(:reason) { decorator.rejection_reason }

    context "when the ASP rejection reason is a cryptic one" do
      let(:payment_request) { create(:asp_payment_request, :rejected, reason: "foo") }

      before do
        allow(ASP::ErrorsDictionary).to receive(:definition).with("foo").and_return(key: :something)
        allow(I18n).to receive(:t).and_call_original
        allow(I18n).to receive(:t).with("asp.errors.something").and_return "nicer error"
      end

      it "uses the right traduction" do
        expect(reason).to eq "nicer error"
      end
    end

    context "when the ASP rejection reason is not registred in the dictionary" do
      let(:payment_request) { create(:asp_payment_request, :rejected, reason: "c'est dimanche") }

      it "uses the original reason" do
        expect(reason).to eq "c'est dimanche"
      end
    end
  end
end
