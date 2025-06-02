# frozen_string_literal: true

require "rails_helper"

describe ASP::PaymentRequestDecorator do
  subject(:decorator) { ActiveDecorator::Decorator.instance.decorate(payment_request) }

  let(:payment_request) { create(:asp_payment_request) }

  describe "unpaid reason" do
    subject(:reason) { decorator.unpaid_reason }

    let(:code_motif) { "ICO" }
    let(:payment_request) { create(:asp_payment_request, :unpaid, code_motif: code_motif) }

    it "finds the right unpaid definition" do
      expect(reason).to eq I18n.t("asp.errors.unpaid.#{ASP::ErrorsDictionary::UNPAID_DEFINITIONS[code_motif.to_sym]}")
    end
  end

  describe "incomplete_reason" do
    subject(:reasons) { decorator.incomplete_reason }

    let(:expected_error) { :excluded_schooling }
    let(:payment_request) { create(:asp_payment_request, :incomplete, incomplete_reason: expected_error) }

    it "finds the right metadata and returns an array of reasons" do
      msg = I18n.t("activerecord.errors.models.asp/payment_request.attributes.ready_state_validation.#{expected_error}")

      expect(reasons).to include(msg)
    end
  end

  describe "rejected_reason" do
    subject(:reason) { decorator.rejected_reason }

    context "when the ASP rejection reason is a cryptic one" do
      let(:payment_request) { create(:asp_payment_request, :rejected, reason: "foo") }

      before do
        allow(ASP::ErrorsDictionary).to receive(:rejected_definition).with("foo").and_return(:something)
        allow(I18n).to receive(:t).and_call_original
        allow(I18n).to receive(:t).with("asp.errors.rejected.responses.something").and_return "nicer error"
      end

      it "uses the right traduction" do
        expect(reason).to eq "nicer error"
      end
    end

    context "when the ASP rejection reason is not registred in the dictionary" do
      let(:payment_request) { create(:asp_payment_request, :rejected, reason: "c'est dimanche") }

      it "uses the original reason" do
        expect(reason).to eq I18n.t("asp.errors.rejected.responses.technical_support")
      end
    end
  end
end
