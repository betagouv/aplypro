# frozen_string_literal: true

require "rails_helper"

describe ASP::PaymentRequestStateMachine do
  subject(:asp_payment_request) { create(:asp_payment_request) }

  let(:student) { asp_payment_request.pfmp.student }

  it { is_expected.to be_in_state :pending }

  shared_examples "a blocked request" do
    it "cannot transition to ready" do
      expect { asp_payment_request.mark_ready! }.to raise_error Statesman::GuardFailedError
    end
  end

  describe "mark_ready!" do
    let(:asp_payment_request) { create(:asp_payment_request, :sendable) }

    context "with the default factory" do
      it "can transition properly" do
        expect { asp_payment_request.mark_ready! }.not_to raise_error
      end
    end

    context "when the request is incomplete" do
      let(:asp_payment_request) { create(:asp_payment_request, :incomplete) }

      it "allows the transition" do
        expect { asp_payment_request.mark_ready! }.not_to raise_error Statesman::TransitionFailedError
      end
    end

    context "when the schooling status is unknown" do
      before { asp_payment_request.schooling.update!(status: nil) }

      it_behaves_like "a blocked request"
    end

    context "when the schooling is for an apprentice" do
      before { asp_payment_request.schooling.update!(status: :apprentice) }

      it_behaves_like "a blocked request"
    end

    context "when the student is a lost record" do
      before { asp_payment_request.student.update!(lost: true) }

      it_behaves_like "a blocked request"
    end

    context "when the RIB has been reused somewhere else" do
      before { create(:rib, iban: asp_payment_request.student.rib.iban) }

      it_behaves_like "a blocked request"
    end

    # rubocop:disable Rails/SkipsModelValidations
    context "when the PFMP is not valid" do
      before { asp_payment_request.pfmp.update_column(:start_date, Date.new(2002, 1, 1)) }

      it_behaves_like "a blocked request"
    end

    context "when the rib is not valid" do
      before { asp_payment_request.student.rib.update_columns(attributes_for(:rib, :outside_sepa)) }

      it_behaves_like "a blocked request"
    end
    # rubocop:enable Rails/SkipsModelValidations

    context "when the request is missing information" do
      before { student.rib&.destroy }

      it_behaves_like "a blocked request"
    end

    context "when the PFMP is zero-amount" do
      before { asp_payment_request.pfmp.update!(amount: 0) }

      it_behaves_like "a blocked request"
    end

    context "when the request belongs to a student over 18 with an external rib" do
      before do
        student.update!(birthdate: 20.years.ago)
        student.rib.update!(personal: false)
      end

      it_behaves_like "a blocked request"
    end

    context "when the attributive decision has not been attached" do
      before do
        asp_payment_request.pfmp.schooling.attributive_decision.detach
      end

      it_behaves_like "a blocked request"
    end
  end

  describe "mark_as_sent!" do
    let(:asp_payment_request) { create(:asp_payment_request, :ready) }
    let!(:request) { create(:asp_request, asp_payment_requests: [asp_payment_request]) }

    it "moves to the sent state" do
      asp_payment_request.mark_as_sent!

      expect(asp_payment_request.reload).to be_in_state :sent
    end

    context "when the target request is not set" do
      before { request.destroy! }

      it "fails the transition" do
        expect { asp_payment_request.reload.mark_as_sent! }.to raise_error(Statesman::GuardFailedError)
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
end
