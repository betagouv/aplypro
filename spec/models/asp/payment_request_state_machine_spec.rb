# frozen_string_literal: true

require "rails_helper"

describe ASP::PaymentRequestStateMachine do
  subject(:asp_payment_request) { create(:asp_payment_request, :pending) }

  let(:student) { asp_payment_request.pfmp.student }

  it { is_expected.to be_in_state :pending }

  it "cannot transition to ready" do
    expect { asp_payment_request.mark_ready! }.to change(asp_payment_request, :current_state)
      .from("pending")
      .to("incomplete")
  end

  describe "mark_sent!" do
    let(:asp_payment_request) { create(:asp_payment_request, :ready) }
    let!(:request) { create(:asp_request, asp_payment_requests: [asp_payment_request]) }

    it "moves to the sent state" do
      asp_payment_request.mark_sent!

      expect(asp_payment_request.reload).to be_in_state :sent
    end

    context "when the target request is not set" do
      before { request.destroy! }

      it "fails the transition" do
        expect { asp_payment_request.reload.mark_sent! }.to raise_error(Statesman::GuardFailedError)
      end
    end
  end

  describe "mark_integrated!" do
    let(:asp_payment_request) { create(:asp_payment_request, :sent) }

    let(:attrs) do
      {
        idIndDoss: "individu",
        idDoss: "dossier",
        idPretaDoss: "prestation"
      }
    end

    it "sets the student's ASP attribute" do
      expect { asp_payment_request.mark_integrated!(attrs) }
        .to change(asp_payment_request.student, :asp_individu_id)
        .from(nil).to("individu")
    end

    it "sets the student's schooling ASP attribute" do
      expect { asp_payment_request.mark_integrated!(attrs) }
        .to change(asp_payment_request.schooling, :asp_dossier_id)
        .from(nil).to("dossier")
    end

    it "sets the PFMP's ASP attribute" do
      expect { asp_payment_request.mark_integrated!(attrs) }
        .to change(asp_payment_request.pfmp, :asp_prestation_dossier_id)
        .from(nil).to("prestation")
    end
  end

  describe "#mark_ready!" do
    context "when there are no issues with the payment request" do
      let(:asp_payment_request) { create(:asp_payment_request, :sendable) }

      it "sets the state to ready" do
        asp_payment_request.mark_ready!

        expect(asp_payment_request).to be_in_state(:ready)
      end
    end

    context "when there are issues with the payment request" do
      let(:asp_payment_request) { create(:asp_payment_request, :sendable_with_issues) }

      before do
        validator_double = instance_double(ASP::PaymentRequestValidator)

        stub_const(
          "ASP::PaymentRequestValidator",
          class_double(ASP::PaymentRequestValidator, new: validator_double)
        )

        allow(validator_double).to receive(:validate) do
          asp_payment_request.errors.add(:ready_state_validation, :excluded_schooling)
        end
      end

      it "raises an incomplete error" do
        expect { asp_payment_request.transition_to!(:ready) }
          .to raise_error(ASP::Errors::IncompletePaymentRequestError)
      end
    end
  end
end
