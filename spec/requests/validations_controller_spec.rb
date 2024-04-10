# frozen_string_literal: true

require "rails_helper"

RSpec.describe ValidationsController do
  let(:schooling) { create(:schooling) }
  let(:student) { schooling.student }
  let(:user) { create(:user, :director, :with_selected_establishment, establishment: schooling.classe.establishment) }
  let(:classe) { schooling.classe }
  let(:pfmp) { create(:pfmp, :completed, schooling: schooling) }

  before { sign_in(user) }

  describe "GET #index" do
    it "renders the :index template" do
      get validations_path

      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
    before { get validation_class_path(classe) }

    it "assigns the requested classe to @classe" do
      expect(assigns(:classe)).to eq classe
    end

    it "renders the :show template" do
      expect(response).to render_template :show
    end
  end

  describe "POST #validate" do
    context "with valid attributes" do
      it "validates selected pfmps" do
        expect do
          post validation_class_path(classe), params: { validation: { pfmp_ids: [pfmp.id] }, confirmed_director: "1" }
        end.to change { pfmp.reload.current_state }.from("completed").to("validated")
      end
    end

    context "with invalid attributes" do
      it "does not validate the pfmp" do
        expect do
          post validation_class_path(classe), params: { validation: { pfmp_ids: [] }, confirmed_director: "0" }
        end.not_to change(pfmp, :current_state)
      end
    end
  end
end
