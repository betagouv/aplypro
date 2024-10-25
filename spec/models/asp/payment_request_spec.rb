# frozen_string_literal: true

require "rails_helper"

RSpec.describe ASP::PaymentRequest do
  subject(:payment_request) { create(:asp_payment_request) }

  describe "associations" do
    it { is_expected.to belong_to(:asp_request).optional }
    it { is_expected.to belong_to(:asp_payment_return).optional }
    it { is_expected.to belong_to(:rib).optional }
  end

  describe "scopes" do
    describe "latest_per_pfmp" do
      let(:pfmp) { create(:pfmp) }
      let(:rejected_payment_requests) { create_list(:asp_payment_request, 3, :rejected) }
      let(:paid_payment_requests) { create_list(:asp_payment_request, 3, :paid) }

      before do
        rejected_payment_requests.each_with_index do |request, i|
          request.update!(pfmp: pfmp, created_at: request.created_at + (i * 10.minutes))
        end
        paid_payment_requests.each_with_index do |request, i|
          request.update!(pfmp: pfmp, created_at: request.created_at + (i * 100.minutes))
        end
      end

      it "takes precedence as a subquery to for filtering records" do
        expect(pfmp.payment_requests.failed.latest_per_pfmp.to_a).to eq []
      end

      it "only returns the last payment requests for a given pfmp based on created_at" do
        expect(pfmp.payment_requests.latest_per_pfmp.to_a).to eq [paid_payment_requests.last]
      end
    end
  end

  describe "active?" do
    subject { create(:asp_payment_request, state) }

    context "when it is rejected" do
      let(:state) { :rejected }

      it { is_expected.not_to be_active }
    end

    context "when it is unpaid" do
      let(:state) { :unpaid }

      it { is_expected.not_to be_active }
    end

    context "when it is sent" do
      let(:state) { :sent }

      it { is_expected.to be_active }
    end
  end

  describe "factories" do
    ASP::PaymentRequestStateMachine.states.each do |state|
      it "has a valid '#{state}' factory" do
        expect(create(:asp_payment_request, state)).to be_valid
      end
    end

    # NOTE: a previous version of the factory was creating 2 records on each call
    # The problem was solved using initialize_with which has different side-effects
    # ex: you cant create additional payment_requests on a Pfmp using factories
    #     create(:asp_payment_request, pfmp: target_pfmp) will not create a new payment request
    it "does not create extra payment requests" do
      expect { create(:asp_payment_request) }.to change(described_class, :count).by(1)
    end
  end

  describe "single_active_payment_request_per_pfmp validation" do
    let(:new_payment_request) { described_class.new(pfmp: existing_payment_request.pfmp) }

    context "when creating a new payment request with an existing active request" do
      let(:existing_payment_request) { create(:asp_payment_request, :sent) }

      it "prevents creating the new request" do
        existing_payment_request.pfmp.reload

        new_payment_request.validate

        expect(new_payment_request.errors).to be_of_kind(:pfmp, :taken)
      end
    end

    context "when creating a new payment request without an existing active request" do
      let(:existing_payment_request) { create(:asp_payment_request, :rejected) }

      it "allows creating the new request" do
        expect(new_payment_request).to be_valid
      end
    end
  end

  describe "mark_ready!" do
    context "when the request is not valid" do
      let(:asp_payment_request) { create(:asp_payment_request, :sendable_with_issues) }

      let(:errors) { %w[missing_rib] }
      let(:expected_metadata) do
        {
          "incomplete_reasons" => {
            "ready_state_validation" => errors.map do |e|
              I18n.t("activerecord.errors.models.asp/payment_request.attributes.ready_state_validation.#{e}")
            end
          }
        }
      end

      it "moves to incomplete" do
        expect { asp_payment_request.mark_ready! }
          .to change(asp_payment_request, :current_state)
          .from("pending").to("incomplete")
      end

      it "sets the metadata on the request" do
        asp_payment_request.mark_ready!

        expect(asp_payment_request.last_transition.metadata).to eq(expected_metadata)
      end

      it "set the rib of the student on the payment request" do
        asp_payment_request.mark_ready!

        expect(asp_payment_request.rib).to eq(asp_payment_request.pfmp.student.rib)
      end
    end
  end

  describe "eligible_for_incomplete_retry?" do
    let(:p_r_incomplete_for_abrogation) do
      create(:asp_payment_request, :incomplete, incomplete_reason: :needs_abrogated_attributive_decision)
    end
    let(:p_r_incomplete_for_missing_da) do
      create(:asp_payment_request, :incomplete, incomplete_reason: :missing_attributive_decision)
    end
    let(:schooling) { create(:schooling, :with_attributive_decision) }
    let(:p_r_incomplete) do
      create(:asp_payment_request, :incomplete, incomplete_reason: :missing_attributive_decision, schooling: schooling)
    end
    let(:p_r_ready) { create(:asp_payment_request, :ready) }

    context "when the payment request is in 'incomplete' state with the abrogation specific error message" do
      it "returns true" do
        expect(p_r_incomplete_for_abrogation.eligible_for_incomplete_retry?).to be true
      end
    end

    context "when the payment request is in 'incomplete' state with the missing DA specific error message" do
      it "returns true" do
        expect(p_r_incomplete_for_missing_da.eligible_for_incomplete_retry?).to be true
      end
    end

    context "when the payment request is not in 'incomplete' state" do
      it "returns false" do
        expect(p_r_ready.eligible_for_incomplete_retry?).to be false
      end
    end
  end

  describe "eligible_for_rejected_or_unpaid_auto_retry?" do
    let(:reasons) { %w[rib bic paiement] }

    context "when the payment request is in 'rejected' state without a RIB reason" do
      let(:p_r) { create(:asp_payment_request, :rejected, reason: "Blabla") }

      it "returns false" do
        expect(p_r.eligible_for_rejected_or_unpaid_auto_retry?(reasons)).to be false
      end
    end

    context "when the payment request is in 'rejected' state with a RIB reason" do
      let(:p_r) do
        create(:asp_payment_request, :rejected, reason: "Test d'une raison de blocage d'un paiement bancaire")
      end

      it "returns true" do
        expect(p_r.eligible_for_rejected_or_unpaid_auto_retry?(reasons)).to be true
      end
    end

    context "when the payment request is in 'unpaid' state without a RIB reason" do
      let(:p_r) { create(:asp_payment_request, :unpaid, reason: "Blabla") }

      it "returns false" do
        expect(p_r.eligible_for_rejected_or_unpaid_auto_retry?(reasons)).to be false
      end
    end

    context "when the payment request is in 'unpaid' state with a RIB reason" do
      let(:p_r) do
        create(:asp_payment_request, :unpaid, reason: "Test d'une raison de blocage d'un paiement bancaire")
      end

      it "returns true" do
        expect(p_r.eligible_for_rejected_or_unpaid_auto_retry?(reasons)).to be true
      end
    end
  end

  describe "#reconstructed_iban" do
    let(:payment_request) { create(:asp_payment_request, :paid) }
    let(:metadata) do
      {
        "PAIEMENT" => {
          "COORDPAIE" => {
            "ZONEBBAN" => "20041010180452191K015",
            "CLECONTROL" => "51",
            "CODEISOPAYS" => "FR"
          }
        }
      }
    end

    before do
      allow(payment_request).to receive(:last_transition).and_return(
        instance_double(ASP::PaymentRequestTransition, metadata: metadata)
      )
    end

    context "when the payment request is in 'paid' state" do
      it "returns the reconstructed IBAN" do
        expect(payment_request.reconstructed_iban).to eq "FR5120041010180452191K015"
      end
    end

    context "when the payment request is not in 'paid' state" do
      let(:payment_request) { create(:asp_payment_request, :pending) }

      it "returns nil" do
        expect(payment_request.reconstructed_iban).to be_nil
      end
    end
  end
end
