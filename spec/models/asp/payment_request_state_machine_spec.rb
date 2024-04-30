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

  shared_examples "a blocked request" do |test_perfect_pfmp_scope = true|
    if test_perfect_pfmp_scope == true
      it "is not included in the Pfmp.perfect scope" do
        expect(Pfmp.perfect).not_to include(asp_payment_request.pfmp)
      end
    end
  end

  describe "mark_ready!" do
    let(:asp_payment_request) { create(:asp_payment_request, :sendable) }

    context "with the default factory" do
      it "can transition properly" do
        expect { asp_payment_request.mark_ready! }.not_to raise_error
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
      before { asp_payment_request.student.update!(ine_not_found: true) }

      it_behaves_like "a blocked request"
    end

    # rubocop:disable Rails/SkipsModelValidations
    context "when the PFMP is not valid" do
      before { asp_payment_request.pfmp.update_column(:start_date, Date.new(2002, 1, 1)) }

      it_behaves_like "a blocked request"
    end

    context "when the rib is not valid" do
      before { asp_payment_request.student.rib.update_columns(attributes_for(:rib, :outside_sepa)) }

      it_behaves_like "a blocked request", test_perfect_pfmp_scope: false
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

      it_behaves_like "a blocked request", test_perfect_pfmp_scope: false
    end

    context "when the attributive decision has not been attached" do
      before { asp_payment_request.pfmp.schooling.attributive_decision.detach }

      it_behaves_like "a blocked request"
    end

    context "when there is another duplicated PFMP" do
      let(:duplicate) do
        pfmp = asp_payment_request.pfmp

        create(
          :pfmp,
          schooling: pfmp.schooling,
          start_date: pfmp.start_date,
          end_date: pfmp.end_date,
          day_count: pfmp.day_count
        )
      end

      context "when it is validated" do
        before { duplicate.validate! }

        it_behaves_like "a blocked request", test_perfect_pfmp_scope: false
      end

      context "when it's not validated" do
        it "allows the transition" do
          expect { asp_payment_request.mark_ready! }.not_to raise_error
        end
      end
    end

    context "when the student lives abroad" do
      before { asp_payment_request.student.update!(address_country_code: "990") }

      it_behaves_like "a blocked request"
    end

    context "when the schooling is excluded" do
      before { create(:exclusion, :whole_establishment, uai: asp_payment_request.schooling.establishment.uai) }

      it_behaves_like "a blocked request", test_perfect_pfmp_scope: false
    end

    context "when the student needs abrogated attributive decisions" do
      before do
        schooling = create(:schooling, :closed, student: asp_payment_request.student)

        create(:pfmp, schooling: schooling)
      end

      it_behaves_like "a blocked request", test_perfect_pfmp_scope: false
    end
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
      let(:expected_metadata) do
        { "incomplete_reasons" => { "ready_state_validation" => [
          I18n.t("activerecord.errors.models.asp/payment_request.attributes.ready_state_validation.eligibility"),
          I18n.t("activerecord.errors.models.asp/payment_request.attributes.ready_state_validation.lives_in_france"),
          I18n.t("activerecord.errors.models.asp/payment_request.attributes.ready_state_validation.rib")
        ] } }
      end

      it "sets the incomplete reason for the issues on the last transition's metadata" do
        asp_payment_request.mark_ready!

        expect(asp_payment_request.last_transition.metadata).to eq expected_metadata
      end
    end
  end
end
