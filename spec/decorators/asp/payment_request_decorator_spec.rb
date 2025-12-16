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
        expect(reason).to eq I18n.t("asp.errors.rejected.responses.fallback_message")
      end
    end
  end

  describe "#last_update_date" do
    subject(:result) { decorator.last_update_date(format: format) }

    let(:format) { :short }

    context "when payment request is paid and has payment date in metadata" do
      let(:payment_date) { "15/03/2024" }
      let(:expected_date) { Date.strptime(payment_date, "%d/%m/%Y") }
      let(:payment_request) { create(:asp_payment_request, :paid) }

      before do
        transition = payment_request.last_transition
        metadata = transition.metadata.merge("PAIEMENT" => { "DATEPAIEMENT" => payment_date })
        transition.update!(metadata: metadata)
        payment_request.reload
      end

      it "returns the formatted payment date from metadata" do
        expect(result).to eq I18n.l(expected_date, format: format)
      end
    end

    context "when payment request is paid but metadata lacks payment date" do
      let(:payment_request) { create(:asp_payment_request, :paid) }

      it "returns the formatted transition updated_at" do
        expect(result).to eq I18n.l(payment_request.last_transition.updated_at, format: format)
      end
    end

    context "when payment request is not paid" do
      let(:payment_request) { create(:asp_payment_request, :sent) }

      it "returns the formatted transition updated_at" do
        expect(result).to eq I18n.l(payment_request.last_transition.updated_at, format: format)
      end
    end

    context "when format is :long" do
      let(:format) { :long }
      let(:payment_request) { create(:asp_payment_request, :sent) }

      it "forwards the format parameter to I18n.l" do
        expect(result).to eq I18n.l(payment_request.last_transition.updated_at, format: :long)
      end
    end

    context "when payment request has no transitions" do
      let(:payment_request) { create(:asp_payment_request) }

      before do
        payment_request.asp_payment_request_transitions.destroy_all
        payment_request.reload
      end

      it "falls back to payment_request updated_at" do
        expect(result).to eq I18n.l(payment_request.updated_at, format: format)
      end
    end
  end
end
