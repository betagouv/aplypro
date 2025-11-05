# frozen_string_literal: true

require "rails_helper"

RSpec.describe Academic::ReportsController do
  let(:user) { create(:academic_user) }

  before do
    school_year = SchoolYear.current
    classe = create(:classe, school_year: school_year)
    establishment = classe.establishment

    sign_in(user)
    allow_any_instance_of(described_class).to receive(:authorised_academy_codes) # rubocop:disable RSpec/AnyInstance
      .and_return([establishment.academy_code])
    allow_any_instance_of(described_class).to receive(:selected_academy).and_return(establishment.academy_code) # rubocop:disable RSpec/AnyInstance
  end

  describe "GET index" do
    it "renders the page successfully" do
      get academic_reports_path
      expect(response).to have_http_status(:success)
    end

    context "when filtering by school year" do
      let(:first_school_year) { create(:school_year, start_year: 2030) }
      let(:second_school_year) { create(:school_year, start_year: 2031) }
      let!(:first_report) { create(:report, school_year: first_school_year) }
      let!(:second_report) { create(:report, school_year: second_school_year) }

      it "shows all reports when no filter is applied" do
        get academic_reports_path
        expect(assigns(:reports)).to include(first_report, second_report)
      end

      it "filters reports by school year" do
        get academic_reports_path(school_year_id: first_school_year.id)
        expect(assigns(:reports)).to include(first_report)
        expect(assigns(:reports)).not_to include(second_report)
      end
    end
  end

  describe "GET show" do
    context "when report exists" do
      let(:report) { create(:report) }

      before { report }

      it "renders the page with report data" do
        get academic_report_path(report)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Statistiques de l&#39;académie")
        expect(response.body).to include("Rapport du")
      end

      it "displays navigation when multiple reports exist" do
        shared_school_year = create(:school_year, start_year: 2080)
        older_report = create(:report, created_at: 1.week.ago, school_year: shared_school_year)
        create(:report, created_at: 1.day.ago, school_year: shared_school_year)
        get academic_report_path(older_report)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Rapport suivant")
      end

      it "displays tooltips with proper ARIA attributes" do
        get academic_report_path(report)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("fr-btn--tooltip")
        expect(response.body).to include("role='tooltip'")
        expect(response.body).to include("aria-describedby='tooltip-stats-")
      end

      it "displays tooltip content for indicators" do
        get academic_report_path(report)
        expect(response.body).to include("Part des décisions d&#39;attributions éditées")
      end
    end

    context "when accessing a specific report" do
      let(:request_school_year) { create(:school_year, start_year: 2090) }
      let(:reports) do
        [
          create(:report, created_at: 1.week.ago, school_year: request_school_year),
          create(:report, created_at: 1.day.ago, school_year: request_school_year)
        ]
      end
      let(:older_report) { reports.first }

      before { reports }

      it "displays the specified report" do
        get academic_report_path(older_report)
        expect(response).to have_http_status(:success)
        expect(assigns(:report)).to eq(older_report)
      end

      it "shows navigation buttons when appropriate" do
        get academic_report_path(older_report)
        expect(response.body).to include("Rapport suivant")
        expect(response.body).not_to include("Rapport précédent")
      end
    end
  end
end
