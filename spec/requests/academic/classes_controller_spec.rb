# frozen_string_literal: true

require "rails_helper"

RSpec.describe Academic::ClassesController do
  let(:school_year) { SchoolYear.current }
  let(:classe) { create(:classe, :with_students, students_count: 3, school_year: school_year) }
  let(:establishment) { classe.establishment }
  let(:user) { create(:academic_user) }

  before do
    sign_in(user)
    allow_any_instance_of(described_class).to receive(:authorised_academy_codes).and_return( # rubocop:disable RSpec/AnyInstance
      [establishment.academy_code]
    )
    allow_any_instance_of(described_class).to receive(:selected_academy).and_return(establishment.academy_code) # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(described_class).to receive(:selected_school_year).and_return(school_year) # rubocop:disable RSpec/AnyInstance
  end

  describe "GET index" do
    it "returns success" do
      get academic_establishment_classes_path(establishment)
      expect(response).to have_http_status(:success)
    end

    it "displays all classes for the establishment" do
      classe1 = create(:classe, establishment: establishment, school_year: school_year, label: "2NDE A")
      classe2 = create(:classe, establishment: establishment, school_year: school_year, label: "1ERE B")
      other_establishment = create(:establishment, academy_code: establishment.academy_code)
      other_classe = create(:classe, establishment: other_establishment, school_year: school_year)

      get academic_establishment_classes_path(establishment)

      expect(response.body).to include(classe1.label)
      expect(response.body).to include(classe2.label)
      expect(response.body).not_to include(other_classe.label)
    end

    it "displays the active students count for each class" do
      classe_with_students = create(
        :classe,
        :with_students,
        students_count: 5,
        establishment: establishment,
        school_year: school_year
      )

      get academic_establishment_classes_path(establishment)

      expect(response.body).to include(classe_with_students.label)
      expect(response.body).to include("5")
    end

    it "only displays classes for the selected school year" do
      old_school_year = create(:school_year, start_year: 2020)
      old_classe = create(:classe, establishment: establishment, school_year: old_school_year, label: "OLD CLASS")
      current_classe = create(:classe, establishment: establishment, school_year: school_year, label: "CURRENT CLASS")

      get academic_establishment_classes_path(establishment)

      expect(response.body).to include(current_classe.label)
      expect(response.body).not_to include(old_classe.label)
    end

    it "returns 404 for establishment with no classes in selected school year" do
      empty_establishment = create(:establishment, academy_code: establishment.academy_code)
      old_school_year = create(:school_year, start_year: 2020)
      create(:classe, establishment: empty_establishment, school_year: old_school_year)

      expect do
        get academic_establishment_classes_path(empty_establishment)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns 404 for establishment from different academy" do
      other_academy_establishment = create(:establishment, academy_code: "99")
      create(:classe, establishment: other_academy_establishment, school_year: school_year)

      expect do
        get academic_establishment_classes_path(other_academy_establishment)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET show" do
    it "returns success" do
      get academic_class_path(classe)
      expect(response).to have_http_status(:success)
    end

    it "displays class information" do
      get academic_class_path(classe)

      expect(response.body).to include(classe.label)
      expect(response.body).to include(classe.mef.label)
      expect(response.body).to include(classe.school_year.to_s)
      expect(response.body).to include(classe.establishment.name)
    end

    it "displays all students in the class" do
      students = classe.active_students

      get academic_class_path(classe)

      students.each do |student|
        expect(response.body).to include(student.last_name)
        expect(response.body).to include(student.first_name)
        expect(response.body).to include(student.ine)
      end
    end

    it "displays attributive decision status for each student" do
      schooling = classe.schoolings.first
      AttributiveDecisionHelpers.generate_fake_attributive_decision(schooling)

      get academic_class_path(classe)

      expect(response.body).to include(schooling.student.last_name)
    end

    it "shows empty state when no students found" do
      empty_classe = create(:classe, establishment: establishment, school_year: school_year)

      get academic_class_path(empty_classe)

      expect(response.body).to include("Aucun élève trouvé dans cette classe")
    end

    it "returns 404 for class from different academy" do
      other_academy_establishment = create(:establishment, academy_code: "99")
      other_classe = create(:classe, establishment: other_academy_establishment, school_year: school_year)

      expect do
        get academic_class_path(other_classe)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns 404 for class from different school year" do
      old_school_year = create(:school_year, start_year: 2020)
      old_classe = create(:classe, establishment: establishment, school_year: old_school_year)

      expect do
        get academic_class_path(old_classe)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
