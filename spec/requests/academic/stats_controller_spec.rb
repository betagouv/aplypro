# frozen_string_literal: true

require "rails_helper"

RSpec.describe Academic::StatsController do
  let(:user) { create(:academic_user) }

  before do
    school_year = SchoolYear.current
    classe = create(:classe, school_year: school_year)
    establishment = classe.establishment

    sign_in(user)
    allow_any_instance_of(described_class).to receive(:authorised_academy_codes) # rubocop:disable RSpec/AnyInstance
      .and_return([establishment.academy_code])
    allow_any_instance_of(described_class).to receive(:selected_academy).and_return(establishment.academy_code) # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(described_class).to receive(:selected_school_year).and_return(school_year) # rubocop:disable RSpec/AnyInstance
  end

  describe "GET index" do
    context "when no reports exist" do
      it "renders the page without data" do
        get academic_stats_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Aucun rapport disponible")
      end
    end

    context "when reports exist" do
      let(:report) { create(:report) }

      before { report }

      it "renders the page with report data" do
        get academic_stats_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Statistiques de l'académie")
        expect(response.body).to include("Rapport du")
      end

      it "displays navigation when multiple reports exist" do
        older_report = create(:report, created_at: 1.week.ago)
        get academic_stats_path(report_id: older_report.id)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Rapport suivant")
      end
    end

    context "when accessing a specific report" do
      let(:reports) do
        [
          create(:report, created_at: 1.week.ago),
          create(:report, created_at: 1.day.ago)
        ]
      end
      let(:older_report) { reports.first }

      before { reports }

      it "displays the specified report" do
        get academic_stats_path(report_id: older_report.id)
        expect(response).to have_http_status(:success)
        expect(assigns(:report)).to eq(older_report)
      end

      it "shows navigation buttons when appropriate" do
        get academic_stats_path(report_id: older_report.id)
        expect(response.body).to include("Rapport suivant")
        expect(response.body).not_to include("Rapport précédent")
      end
    end
  end
end
