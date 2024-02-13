# frozen_string_literal: true

require "rails_helper"

RSpec.describe ASP::PaymentRequest do
  subject(:asp_payment_request) { create(:asp_payment_request) }

  describe "associations" do
    it { is_expected.to belong_to(:payment) }
    it { is_expected.to belong_to(:asp_request) }
  end

  describe "state machine" do
    it { is_expected.to be_in_state :pending }

    describe "mark_integrated!" do
      let(:attrs) do
        {
          idIndDoss: "individu",
          idDoss: "dossier",
          idPretaDoss: "prestation"
        }
      end

      before do
        asp_payment_request.mark_as_sent!
      end

      it "sets the student's ASP attribute" do
        expect { asp_payment_request.mark_integrated!(attrs) }
          .to change(asp_payment_request.payment.student, :asp_individu_id)
          .from(nil).to("individu")
      end

      it "sets the student's schooling ASP attribute" do
        expect { asp_payment_request.mark_integrated!(attrs) }
          .to change(asp_payment_request.payment.schooling, :asp_dossier_id)
          .from(nil).to("dossier")
      end

      it "sets the PFMP's ASP attribute" do
        expect { asp_payment_request.mark_integrated!(attrs) }
          .to change(asp_payment_request.payment.pfmp, :asp_prestation_dossier_id)
          .from(nil).to("prestation")
      end
    end
  end
end
