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

    context "when there's a unique constraint violation on asp_individu_id" do
      let(:duplicate_student) { create(:student, asp_individu_id: "individu") }
      let(:merger) { instance_double(StudentMerger) }

      before do
        error_message = "Key (asp_individu_id)=(individu) already exists. \
          Duplicate error on index_students_on_asp_individu_id"

        allow(asp_payment_request.student).to receive(:update!)
          .and_raise(ActiveRecord::RecordNotUnique.new(error_message))

        allow(asp_payment_request.student).to receive(:duplicates).and_return([duplicate_student])
        allow(StudentMerger).to receive(:new).with([duplicate_student]).and_return(merger)
        allow(merger).to receive(:merge!).and_return(true)
      end

      it "raises an integration error" do
        expect do
          asp_payment_request.mark_integrated!(attrs)
        end.to raise_error(ASP::Errors::IntegrationError, /CSV Integration error/)
      end
    end
  end

  describe "#mark_ready!" do
    context "when there are no issues with the payment request" do
      let(:asp_payment_request) { create(:asp_payment_request, :sendable) }

      it "sets the state to ready" do
        asp_payment_request.mark_ready!

        expect(asp_payment_request).to be_in_state(:ready)
      end

      describe "the necessary funds" do
        let(:asp_payment_request) { create(:asp_payment_request, :sendable) }

        it "set the state to ready when there are the necessary funds" do
          allow(asp_payment_request).to receive(:payable?).and_return(true)
          asp_payment_request.mark_ready!

          expect(asp_payment_request).to be_in_state(:ready)
        end

        it "raises a funding error when there are no longer the necessary funds" do
          allow(asp_payment_request).to receive(:payable?).and_return(false)

          expect { asp_payment_request.transition_to!(:ready) }
            .to raise_error(ASP::Errors::FundingNotAvailableError)
        end
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
