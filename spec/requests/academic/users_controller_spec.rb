# frozen_string_literal: true

require "rails_helper"

RSpec.describe Academic::UsersController do
  let(:user) { create(:academic_user) }

  before do
    sign_in(user)
    allow_any_instance_of(described_class).to receive(:authorised_academy_codes).and_return(["01"]) # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(described_class).to receive(:selected_academy).and_return("01") # rubocop:disable RSpec/AnyInstance
  end

  describe "GET index" do
    let(:establishment) { create(:establishment, academy_code: "01") }
    let(:other_academy_establishment) { create(:establishment, academy_code: "02") }
    let(:another_establishment) { create(:establishment, academy_code: "01") }

    it "returns success" do
      get academic_users_path

      expect(response).to have_http_status(:success)
    end

    it "displays all users from the selected academy" do
      director = create(:user, :director, establishment: establishment)
      authorised_user = create(:user, :authorised, establishment: establishment)
      create(:user, :director, establishment: other_academy_establishment)

      get academic_users_path

      expect(response.body).to include(director.name)
      expect(response.body).to include(authorised_user.name)
      expect(response.body).not_to include("Aucun utilisateur trouvé")
    end

    it "filters users by director role" do
      director = create(:user, :director, establishment: establishment)
      authorised_user = create(:user, :authorised, establishment: establishment)

      get academic_users_path(role: :dir)

      expect(response.body).to include(director.name)
      expect(response.body).not_to include(authorised_user.name)
    end

    it "filters users by authorised role" do
      director = create(:user, :director, establishment: establishment)
      authorised_user = create(:user, :authorised, establishment: establishment)

      get academic_users_path(role: :authorised)

      expect(response.body).not_to include(director.name)
      expect(response.body).to include(authorised_user.name)
    end

    it "displays users with multiple roles in the same academy" do
      user_with_multiple_roles = create(:user, :director, establishment: establishment)
      EstablishmentUserRole.create!(
        user: user_with_multiple_roles,
        establishment: another_establishment,
        role: :authorised
      )

      get academic_users_path

      expect(response.body).to include(user_with_multiple_roles.name)
      expect(response.body).to include("Directeur")
      expect(response.body).to include("Habilité")
    end

    it "shows empty state when no users found" do
      get academic_users_path

      expect(response.body).to include("Aucun utilisateur trouvé pour cette académie")
    end

    it "does not display users from other academies" do
      other_academy_user = create(:user, :director, establishment: other_academy_establishment)

      get academic_users_path

      expect(response.body).not_to include(other_academy_user.name)
    end
  end
end
