# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolingsController do
  let(:schooling) { create(:schooling, :with_attributive_decision) }
  let(:payment_request) { create(:asp_payment_request, :incomplete_for_missing_abrogation_da) }

  let(:user) do
    create(:user, :director, :with_selected_establishment, establishment: schooling.student.classe.establishment)
  end

  before do
    sign_in(user)
    schooling.pfmps = [payment_request.pfmp]
    schooling.save!
    Timecop.safe_mode = false
    Timecop.freeze(Date.new(2024, 6, 21))
  end

  after do
    Timecop.return
  end

  describe "retry_eligibile_payment_requests" do
    before do
      schooling.update!(end_date: Date.parse("2024-06-20"))
    end

    it "retries eligible payment requests" do
      delete abrogate_decision_school_year_class_schooling_path(schooling.classe.school_year,
                                                                class_id: schooling.classe.id,
                                                                id: schooling.id),
             params: { confirmed_director: "1" }
      expect(payment_request).to be_in_state :ready
    end
  end
end
