# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolingsController do
  let(:schooling) { create(:schooling, :with_attributive_decision) }
  let(:student) { schooling.student }
  let(:user) { create(:user, :director, :with_selected_establishment, establishment: student.classe.establishment) }

  before { sign_in(user) }

  describe "DEL /abrogate_decision" do
    it "enqueues a job to generate the abrogation document" do
      expect(GenerateAbrogationDecisionJob).to receive(:perform_now).with(schooling) # rubocop:disable RSpec/MessageSpies
      delete abrogate_decision_school_year_class_schooling_path(SchoolYear.current,
                                                                class_id: schooling.classe.id,
                                                                id: schooling.id),
             params: { confirmed_director: "1" }
    end
  end
end
