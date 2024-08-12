# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe PfmpsController do
  let(:school_year) { SchoolYear.current }
  let(:schooling) { create(:schooling) }
  let(:student) { schooling.student }
  let(:user) { create(:user, :director, :with_selected_establishment, establishment: schooling.classe.establishment) }
  let(:pfmp) { create(:pfmp, schooling: schooling) }

  before { sign_in(user) }

  describe "GET /pfmp" do
    before do
      get school_year_class_schooling_pfmp_path(school_year,
                                                class_id: schooling.classe.id,
                                                schooling_id: schooling.id,
                                                id: pfmp.id)
    end

    it { is_expected.to render_template(:show) }

    context "when trying to access a PFMP from another establishment" do
      before do
        schooling = create(:schooling)
        get school_year_class_schooling_pfmp_path(school_year,
                                                  class_id: schooling.classe.id,
                                                  schooling_id: schooling.id,
                                                  id: pfmp.id)
      end

      it { is_expected.to redirect_to school_year_classes_path(SchoolYear.current) }
    end

    context "when trying to access a deleted PFMP" do
      before do
        pfmp.destroy!

        get school_year_class_schooling_pfmp_path(school_year,
                                                  class_id: schooling.classe.id,
                                                  schooling_id: schooling.id,
                                                  id: pfmp.id)
      end

      it "redirect" do
        expect(response).to redirect_to student_path(student)
      end
    end
  end

  describe "POST /validate" do
    let(:pfmp) { create(:pfmp, :completed, schooling: schooling) }

    context "when validating as a director" do
      it "returns found (but there is an error flash on the page)" do
        post validate_school_year_class_schooling_pfmp_path(school_year,
                                                            class_id: schooling.classe.id,
                                                            schooling_id: schooling.id,
                                                            id: pfmp.id)

        expect(response).to have_http_status(:found)
      end
    end

    context "when validating as a confirmed director" do
      let(:user) do
        create(:user, :confirmed_director, :with_selected_establishment, establishment: schooling.classe.establishment)
      end

      it "returns 200" do
        post validate_school_year_class_schooling_pfmp_path(school_year,
                                                            class_id: schooling.classe.id,
                                                            schooling_id: schooling.id,
                                                            id: pfmp.id)

        expect(response).to have_http_status(:found)
      end
    end

    context "when validating as an authorised personnel" do
      let(:user) do
        create(
          :user,
          :authorised,
          :with_selected_establishment,
          establishment: student.classe.establishment
        )
      end

      it "returns 403 (Forbidden)" do
        post validate_school_year_class_schooling_pfmp_path(school_year,
                                                            class_id: schooling.classe.id,
                                                            schooling_id: schooling.id,
                                                            id: pfmp.id)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /pfmp" do
    let(:pfmp) { build(:pfmp, schooling: schooling) }
    let(:pfmp_params) { { pfmp: pfmp.attributes } }

    it "returns 200" do
      post school_year_class_schooling_pfmps_path(school_year,
                                                  class_id: schooling.classe.id,
                                                  schooling_id: schooling.id), params: pfmp_params

      expect(response).to have_http_status(:found)
    end

    context "with a closed schooling" do
      let(:schooling) { create(:schooling, :closed) }

      it "returns 200" do
        post school_year_class_schooling_pfmps_path(school_year,
                                                    class_id: schooling.classe.id,
                                                    schooling_id: schooling.id), params: pfmp_params

        expect(response).to have_http_status(:found)
      end
    end
  end

  describe "POST /rectify" do
    let(:pfmp) do
      pfmp = create(:asp_payment_request, :paid).pfmp.reload
      pfmp.update!(schooling: schooling)
      pfmp
    end
    let(:new_start_date) { pfmp.start_date + 2.days }
    let(:pfmp_params) { { start_date: new_start_date, end_date: pfmp.end_date, day_count: 5 } }
    let(:addresse_params) { { address_line1: "123 New St", address_city: "New City" } }

    context "when the PFMP can be rectified" do
      it "rectifies the PFMP and redirects with a success notice" do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
        post rectify_school_year_class_schooling_pfmp_path(school_year, class_id: pfmp.classe.id, schooling_id: pfmp.schooling.id, id: pfmp.id),
             params: { pfmp: pfmp_params, addresse: addresse_params, confirmed_director: "1" }

        expect(flash[:notice]).to eq(I18n.t("flash.pfmps.rectified"))
        expect(pfmp.reload.attributes.slice("start_date", "end_date", "day_count", "current_state"))
          .to eq("start_date" => new_start_date, "end_date" => pfmp_params[:end_date], "day_count" => 5)
        expect(pfmp).to be_in_state(:rectified)
      end
    end

    context "when the PFMP cannot be rectified" do
      let(:pfmp) { create(:pfmp, :validated, schooling: schooling) }

      it "redirects with an alert" do # rubocop:disable RSpec/MultipleExpectations
        post rectify_school_year_class_schooling_pfmp_path(
          school_year, class_id: pfmp.classe.id, schooling_id: pfmp.schooling.id, id: pfmp.id
        ), params: { pfmp: pfmp_params, addresse: addresse_params, confirmed_director: "1" }

        expect(flash[:alert]).to eq(I18n.t("flash.pfmps.cannot_rectify"))
        expect(pfmp).to be_in_state(:validated)
      end
    end

    context "when the PFMP update is invalid" do
      let(:pfmp_params) { { start_date: pfmp.end_date + 1.day, end_date: pfmp.end_date } }

      it "renders the confirm_rectification template with unprocessable_entity status" do
        post rectify_school_year_class_schooling_pfmp_path(
          school_year, class_id: pfmp.classe.id, schooling_id: pfmp.schooling.id, id: pfmp.id
        ), params: { pfmp: pfmp_params, addresse: addresse_params, confirmed_director: "1" }

        expect(pfmp).to be_in_state(:validated)
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
