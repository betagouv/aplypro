# frozen_string_literal: true

require "rails_helper"

RSpec.describe Academic::ToolsController do
  let(:user) { create(:academic_user) }

  before do
    sign_in(user)
    allow_any_instance_of(described_class).to receive(:authorised_academy_codes).and_return(["01"]) # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(described_class).to receive(:selected_academy).and_return("01") # rubocop:disable RSpec/AnyInstance
    allow(Keycloak::RemoveUserJob).to receive(:perform_later)
  end

  describe "GET index" do
    it "renders tools page" do
      get academic_tools_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST remove_keycloak_user" do
    it "enqueues removal job and shows loading state" do
      post remove_keycloak_user_academic_tools_path, params: { email: "user@example.com" }, as: :turbo_stream

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Suppression en cours...")
      expect(Keycloak::RemoveUserJob).to have_received(:perform_later)
        .with("user@example.com", "keycloak_removal_status")
    end
  end

  describe "POST invite_keycloak_user" do
    before do
      allow(Keycloak::InviteAcademicUserJob).to receive(:perform_later)
    end

    it "enqueues invite job with filtered academy codes" do
      post invite_keycloak_user_academic_tools_path, params: { email: "user@example.com", academy_codes: ["", "44"] }, as: :turbo_stream

      expect(response).to have_http_status(:success)
      expect(Keycloak::InviteAcademicUserJob).to have_received(:perform_later)
        .with("user@example.com", ["44"], "keycloak_invitation_status")
    end

    it "handles multiple academy codes" do
      post invite_keycloak_user_academic_tools_path, params: { email: "user@example.com", academy_codes: ["", "44", "06"] }, as: :turbo_stream

      expect(response).to have_http_status(:success)
      expect(Keycloak::InviteAcademicUserJob).to have_received(:perform_later)
        .with("user@example.com", %w[44 06], "keycloak_invitation_status")
    end
  end
end
