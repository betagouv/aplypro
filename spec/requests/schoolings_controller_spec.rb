# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolingsController do
  let(:student) { schooling.student }
  let(:user) { create(:user, :director, :with_selected_establishment, establishment: student.classe.establishment) }

  let(:schooling) { create(:schooling, :with_attributive_decision) }
  let(:payment_request_missing_da) { create(:asp_payment_request, :incomplete_for_missing_abrogation_da) }
  let(:payment_request) { create(:asp_payment_request, :incomplete) }

  # rubocop:disable Layout/LineLength
  error_message = I18n.t("activerecord.errors.models.asp/payment_request.attributes.ready_state_validation.needs_abrogated_attributive_decision")
  # rubocop:enable Layout/LineLength

  before do
    sign_in(user)
    schooling.pfmps = [payment_request_missing_da.pfmp]
    schooling.save!
    Timecop.safe_mode = false
    Timecop.freeze(Date.new(2024, 6, 21))
  end

  after do
    Timecop.return
  end

  describe "DEL /abrogate_decision" do
    it "enqueues a job to generate the abrogation document" do
      expect(GenerateAbrogationDecisionJob).to receive(:perform_now).with(schooling) # rubocop:disable RSpec/MessageSpies
      delete abrogate_decision_school_year_class_schooling_path(SchoolYear.current,
                                                                class_id: schooling.classe.id,
                                                                id: schooling.id),
             params: { confirmed_director: "1" }
    end
  end

  describe "retry_eligibile_payment_requests" do
    before do
      schooling.update!(end_date: Date.current, start_date: Date.current - 1.day)
    end

    context "when the payment request is retry eligible" do
      it "Does not return abrogated decision error" do
        delete abrogate_decision_school_year_class_schooling_path(schooling.classe.school_year,
                                                                  class_id: schooling.classe.id, id: schooling.id),
               params: { confirmed_director: "1" }
        expect(payment_request_missing_da.last_transition.metadata).not_to include(error_message)
      end
    end

    context "when the payment request is retry eligible" do
      it "Does not return abrogated decision error" do
        schooling.pfmps = [payment_request.pfmp]
        schooling.save!
        delete abrogate_decision_school_year_class_schooling_path(schooling.classe.school_year,
                                                                  class_id: schooling.classe.id, id: schooling.id),
               params: { confirmed_director: "1" }
        expect(payment_request.last_transition.metadata).to include(error_message)
      end
    end

    context "when the payment request is not retry eligible" do
      let(:pfmp) { create(:pfmp, :completed) }

      before do
        schooling.update!(pfmps: [pfmp])
      end

      it "Returns abrogated decision error" do
        delete abrogate_decision_school_year_class_schooling_path(schooling.classe.school_year,
                                                                  class_id: schooling.classe.id, id: schooling.id),
               params: { confirmed_director: "1" }
        expect(payment_request_missing_da.current_state).not_to eq(:ready)
      end
    end
  end
end
