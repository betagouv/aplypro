# frozen_string_literal: true

require "rails_helper"

RSpec.describe Academic::EstablishmentsController do
  let(:school_year) { SchoolYear.current }
  let(:classe) { create(:classe, school_year: school_year) }
  let(:establishment) { classe.establishment }
  let(:user) { create(:academic_user) }

  before do
    data_row = Array.new(Report::HEADERS.length, 0)
    create(:report, school_year: school_year, data: {
             "establishments_data" => [
               %w[uai establishment_name ministry academy private_or_public] + Report::HEADERS.map(&:to_s),
               [establishment.uai, establishment.name, "MENJ", establishment.academy_label, "Public"] + data_row
             ]
           })

    sign_in(user)
    allow_any_instance_of(described_class).to receive(:authorised_academy_codes).and_return( # rubocop:disable RSpec/AnyInstance
      [establishment.academy_code]
    )
    allow_any_instance_of(described_class).to receive(:selected_academy).and_return(establishment.academy_code) # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(described_class).to receive(:selected_school_year).and_return(school_year) # rubocop:disable RSpec/AnyInstance
  end

  describe "GET show" do
    it "returns success" do
      get academic_establishment_path(establishment)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET users" do
    it "returns success" do
      get users_academic_establishment_path(establishment)
      expect(response).to have_http_status(:success)
    end

    it "displays all users from the establishment" do
      director = create(:user, :director, establishment: establishment)
      authorised_user = create(:user, :authorised, establishment: establishment)
      other_establishment = create(:establishment, academy_code: establishment.academy_code)
      other_user = create(:user, :director, establishment: other_establishment)

      get users_academic_establishment_path(establishment)

      expect(response.body).to include(director.name)
      expect(response.body).to include(authorised_user.name)
      expect(response.body).not_to include(other_user.name)
      expect(response.body).not_to include("Aucun utilisateur trouvé")
    end

    it "filters users by director role" do
      director = create(:user, :director, establishment: establishment)
      authorised_user = create(:user, :authorised, establishment: establishment)

      get users_academic_establishment_path(establishment, role: :dir)

      expect(response.body).to include(director.name)
      expect(response.body).not_to include(authorised_user.name)
    end

    it "filters users by authorised role" do
      director = create(:user, :director, establishment: establishment)
      authorised_user = create(:user, :authorised, establishment: establishment)

      get users_academic_establishment_path(establishment, role: :authorised)

      expect(response.body).not_to include(director.name)
      expect(response.body).to include(authorised_user.name)
    end

    it "displays users with roles in multiple establishments" do
      user_with_roles = create(:user, :director, establishment: establishment)
      other_establishment = create(:establishment, academy_code: establishment.academy_code)
      EstablishmentUserRole.create!(
        user: user_with_roles,
        establishment: other_establishment,
        role: :authorised
      )

      get users_academic_establishment_path(establishment)

      expect(response.body).to include(user_with_roles.name)
      expect(response.body).to include("Directeur")
    end

    it "shows confirmed director badge" do
      director = create(:user, :director, establishment: establishment)
      establishment.update(confirmed_director: director)

      get users_academic_establishment_path(establishment)

      expect(response.body).to include(director.name)
      expect(response.body).to include("Confirmé")
    end

    it "shows empty state when no users found" do
      empty_establishment = create(:establishment, academy_code: establishment.academy_code)
      create(:classe, establishment: empty_establishment, school_year: SchoolYear.current)

      get users_academic_establishment_path(empty_establishment)

      expect(response.body).to include("Aucun utilisateur trouvé pour cet établissement")
    end

    it "sorts users by name by default" do
      create(:user, :director, establishment: establishment, name: "Zorro Diego")
      create(:user, :director, establishment: establishment, name: "Alvarez Ana")

      get users_academic_establishment_path(establishment)

      body_text = response.body.gsub(/\s+/, " ")
      expect(body_text.index("Alvarez Ana")).to be < body_text.index("Zorro Diego")
    end

    it "sorts users by email when specified" do
      create(:user, :director, establishment: establishment, email: "zzz@example.com")
      create(:user, :director, establishment: establishment, email: "aaa@example.com")

      get users_academic_establishment_path(establishment, sort: "email")

      body_text = response.body.gsub(/\s+/, " ")
      expect(body_text.index("aaa@example.com")).to be < body_text.index("zzz@example.com")
    end

    it "sorts users by last sign in when specified" do
      user_recent = create(:user, :director, establishment: establishment, last_sign_in_at: 1.day.ago)
      user_old = create(:user, :director, establishment: establishment, last_sign_in_at: 10.days.ago)

      get users_academic_establishment_path(establishment, sort: "last_sign_in")

      body_text = response.body.gsub(/\s+/, " ")
      expect(body_text.index(user_recent.name)).to be < body_text.index(user_old.name)
    end
  end
end
