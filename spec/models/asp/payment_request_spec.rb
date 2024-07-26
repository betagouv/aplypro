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

      let(:errors) { %w[doesnt_live_in_france missing_rib] }
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

  describe "eligible_for_auto_retry?" do
    let(:p_r_incomplete_for_abrogation) { create(:asp_payment_request, :incomplete_for_missing_abrogation_da) }
    let(:p_r_incomplete_for_missing_da) { create(:asp_payment_request, :incomplete_for_missing_da) }
    let(:schooling) { create(:schooling, :with_attributive_decision) }
    let(:p_r_incomplete) { create(:asp_payment_request, :incomplete, schooling: schooling) }
    let(:p_r_ready) { create(:asp_payment_request, :ready) }

    context "when the payment request is in 'incomplete' state with the abrogation specific error message" do
      it "returns true" do
        expect(p_r_incomplete_for_abrogation.eligible_for_auto_retry?).to be true
      end
    end

    context "when the payment request is in 'incomplete' state with the missing DA specific error message" do
      it "returns true" do
        expect(p_r_incomplete_for_missing_da.eligible_for_auto_retry?).to be true
      end
    end

    context "when the payment request is not in 'incomplete' state" do
      it "returns false" do
        expect(p_r_ready.eligible_for_auto_retry?).to be false
      end
    end

    context "when the payment request is in 'incomplete' state without any specific error message" do
      it "returns true" do
        expect(p_r_incomplete.eligible_for_auto_retry?).to be false
      end
    end
  end
end
