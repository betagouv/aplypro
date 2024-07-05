# frozen_string_literal: true

require "rails_helper"

RSpec.describe ClassesController do
  let(:school_year) { SchoolYear.current }
  let(:classe) { create(:classe, school_year: school_year) }
  let(:establishment) { classe.establishment }
  let(:user) { create(:user, :director, :with_selected_establishment, establishment: establishment) }

  before { sign_in(user) }

  describe "GET /index" do
    it "returns a list of classes" do
      get school_year_classes_path(school_year)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /classe" do
    before do
      get school_year_class_path(school_year, classe)
    end

    it { is_expected.to render_template(:show) }

    context "when the classe doesn't belong to the establishment of the user" do
      before do
        get school_year_class_path(school_year, create(:classe))
      end

      it { is_expected.to redirect_to school_year_classes_path(school_year) }
    end
  end
end
