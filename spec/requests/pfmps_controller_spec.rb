# frozen_string_literal: true

require "rails_helper"

RSpec.describe PfmpsController do
  let(:schooling) { create(:schooling) }
  let(:student) { schooling.student }
  let(:user) { create(:user, :director, :with_selected_establishment, establishment: schooling.classe.establishment) }
  let(:pfmp) { create(:pfmp, schooling: schooling) }

  before { sign_in(user) }

  describe "GET /pfmp" do
    before do
      get class_schooling_pfmp_path(class_id: schooling.classe.id, schooling_id: schooling.id, id: pfmp.id)
    end

    it { is_expected.to render_template(:show) }

    context "when trying to access a PFMP from another establishment" do
      before do
        schooling = create(:schooling)
        get class_schooling_pfmp_path(class_id: schooling.classe.id, schooling_id: schooling.id, id: pfmp.id)
      end

      it { is_expected.to redirect_to classes_path }
    end

    context "when trying to access a deleted PFMP" do
      before do
        pfmp.destroy!

        get class_schooling_pfmp_path(class_id: schooling.classe.id, schooling_id: schooling.id, id: pfmp.id)
      end

      it { is_expected.to redirect_to class_student_path(schooling.classe, student) }
    end
  end

  describe "POST /validate" do
    let(:pfmp) { create(:pfmp, :completed, schooling: schooling) }

    context "when validating as a director" do
      it "returns forbidden" do
        post validate_class_schooling_pfmp_path(class_id: schooling.classe.id, schooling_id: schooling.id, id: pfmp.id)

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when validating as a confirmed director" do
      let(:user) do
        create(:user, :confirmed_director, :with_selected_establishment, establishment: schooling.classe.establishment)
      end

      it "returns 200" do
        post validate_class_schooling_pfmp_path(class_id: schooling.classe.id, schooling_id: schooling.id, id: pfmp.id)

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
        post validate_class_schooling_pfmp_path(class_id: schooling.classe.id, schooling_id: schooling.id, id: pfmp.id)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /pfmp" do
    let(:pfmp) { build(:pfmp, schooling: schooling) }
    let(:pfmp_params) { { pfmp: pfmp.attributes } }

    it "returns 200" do
      post class_schooling_pfmps_path(class_id: schooling.classe.id, schooling_id: schooling.id), params: pfmp_params

      expect(response).to have_http_status(:found)
    end

    context "with a closed schooling" do
      let(:schooling) { create(:schooling, :closed) }

      it "returns 200" do
        post class_schooling_pfmps_path(class_id: schooling.classe.id, schooling_id: schooling.id), params: pfmp_params

        expect(response).to have_http_status(:found)
      end
    end
  end
end
