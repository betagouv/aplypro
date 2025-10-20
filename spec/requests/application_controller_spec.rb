# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController do
  let(:school_year) { SchoolYear.current }
  let(:establishment) { create(:establishment) }
  let(:establishment_user) { create(:user, :director, :with_selected_establishment, establishment: establishment) }
  let(:academic_user) { create(:academic_user) }
  let(:asp_user) do
    ASP::User.create!(
      uid: "asp123",
      name: "ASP User",
      provider: "asp",
      email: "test@asp-public.fr"
    )
  end

  describe "redirect_academic_users!" do
    context "when only an academic user is signed in" do
      before { sign_in(academic_user, scope: :academic_user) }

      it "redirects to academic_home_path" do
        get school_year_classes_path(school_year)
        expect(response).to redirect_to(academic_home_path)
      end
    end

    context "when both academic and establishment users are signed in" do
      before do
        sign_in(academic_user, scope: :academic_user)
        sign_in(establishment_user, scope: :user)
      end

      it "does not redirect and allows access to establishment routes" do
        get school_year_classes_path(school_year)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when only an establishment user is signed in" do
      before { sign_in(establishment_user, scope: :user) }

      it "does not redirect" do
        get school_year_classes_path(school_year)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "redirect_asp_users!" do
    context "when only an ASP user is signed in" do
      before { sign_in(asp_user, scope: :asp_user) }

      it "redirects to asp_schoolings_path" do
        get school_year_classes_path(school_year)
        expect(response).to redirect_to(asp_schoolings_path)
      end
    end

    context "when both ASP and establishment users are signed in" do
      before do
        sign_in(asp_user, scope: :asp_user)
        sign_in(establishment_user, scope: :user)
      end

      it "does not redirect and allows access to establishment routes" do
        get school_year_classes_path(school_year)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
