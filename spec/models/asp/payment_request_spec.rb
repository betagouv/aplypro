# frozen_string_literal: true

require "rails_helper"

RSpec.describe ASP::PaymentRequest do
  subject(:asp_payment_request) { create(:asp_payment_request) }

  describe "associations" do
    it { is_expected.to belong_to(:asp_request).optional }
  end

  describe "state machine" do
    it { is_expected.to be_in_state :pending }

    describe "mark_ready!" do
      context "when the request is incomplete" do
        let(:asp_payment_request) { create(:asp_payment_request, :incomplete) }

        it "allows the transition" do
          expect { asp_payment_request.mark_ready! }.not_to raise_error Statesman::TransitionFailedError
        end

        it "fails the guard" do
          expect { asp_payment_request.mark_ready! }.to raise_error Statesman::GuardFailedError
        end
      end

      context "when the request is missing information" do
        before { asp_payment_request.student.rib&.destroy }

        it "blocks the transition" do
          expect { asp_payment_request.mark_ready! }.to raise_error Statesman::GuardFailedError
        end
      end

      context "when the request belongs to a student over 18 with an external rib" do
        let(:student) { create(:student, :with_all_asp_info, :adult) }

        before do
          asp_payment_request.pfmp.update!(student: student)
          student.rib.update!(personal: false)
        end

        it "blocks the transition" do
          expect { asp_payment_request.mark_ready! }.to raise_error Statesman::GuardFailedError
        end
      end
    end

    describe "mark_as_sent!" do
      subject(:asp_payment_request) { create(:asp_payment_request, :ready) }

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
      subject(:asp_payment_request) { create(:asp_payment_request, :sent) }

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
end
