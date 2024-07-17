# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolingsController do
  let(:schooling) { create(:schooling, :with_attributive_decision) }
  let(:pfmp) { create(:pfmp, :validated, schooling: schooling) }
  let(:payment_request) { create(:asp_payment_request, :incomplete_for_missing_abrogation_da, pfmp: pfmp) }

  let(:student) { schooling.student }
  let(:user) { create(:user, :director, :with_selected_establishment, establishment: student.classe.establishment) }

  before do
    sign_in(user)
    Timecop.safe_mode = false
    Timecop.freeze(Date.new(2024, 6, 21))
  end

  after do
    Timecop.return
  end

  describe "retry_eligibile_payment_requests" do
    before {
      schooling.update!(end_date: Date.parse("2024-06-20"))
      pfmp.reload
    }
    it "retries eligible payment requests" do
      binding.irb
      delete abrogate_decision_school_year_class_schooling_path(schooling.classe.school_year,
                                                                class_id: schooling.classe.id,
                                                                id: schooling.id),
             params: { confirmed_director: "1" }
      expect(payment_request).to be_in_state :ready
    end
  end
end
