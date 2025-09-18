# frozen_string_literal: true

require "rails_helper"

RSpec.describe Classe do
  subject(:classe) { build(:classe) }

  describe "associations" do
    it { is_expected.to belong_to(:establishment).class_name("Establishment") }
    it { is_expected.to belong_to(:mef).class_name("Mef") }
    it { is_expected.to belong_to(:school_year).class_name("SchoolYear") }
    it { is_expected.to have_many(:students).order(%i[last_name first_name]) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:label) }
  end

  describe ".current" do
    let(:current) { create(:classe, school_year: SchoolYear.current) }

    it "returns the classes of the current school year" do
      expect(described_class.current).to contain_exactly(current)
    end
  end

  describe ".for_year" do
    let(:year) { 2020 }
    let(:school_year) { create(:school_year, start_year: year) }
    let(:classe) { create(:classe, school_year: school_year) }

    it "returns the classes of the current school year" do
      expect(described_class.for_year(year)).to contain_exactly(classe)
    end
  end

  describe "create_bulk_pfmp" do
    subject(:classe) { create(:classe, :with_students, students_count: 5) }

    let(:params) do
      {
        start_date: Date.parse("#{SchoolYear.current.start_year}-10-08"),
        end_date: Date.parse("#{SchoolYear.current.start_year}-10-11")
      }
    end

    it "creates a PFMP for each student" do
      expect { classe.create_bulk_pfmp(params) }.to change(Pfmp, :count).from(0).to(5)
    end

    context "when there are past/gone students" do
      it "does not include them" do
        student = classe.students.last

        student.close_current_schooling!("#{SchoolYear.current.end_year}-08-27")

        expect { classe.create_bulk_pfmp(params) }.not_to change(student, :pfmps)
      end
    end
  end

  describe "#active_students" do
    subject(:active_students) { classe.active_students }

    let(:classe) { create(:classe, :with_students, students_count: 5) }
    let(:closed_schooling) { create(:schooling, :closed, classe: classe) }

    it { is_expected.to have_attributes(count: 5) }
    it { is_expected.not_to include closed_schooling.student }

    it "orders them by last name" do
      students = %w[Z A B M C].map { |name| create(:student, last_name: name) }

      classe.students = students

      expect(active_students.map(&:last_name).join).to eq "ABCMZ"
    end
  end

  describe "inactive_students" do
    subject(:inactive_students) { classe.inactive_students }

    let(:classe) { create(:classe, :with_former_students, students_count: 5) }
    let(:current_schooling) { create(:schooling, classe: classe) }

    it { is_expected.to have_attributes(count: 5) }
    it { is_expected.not_to include current_schooling.student }

    it "orders them by last name" do
      names = %w[Z A B M C]
      classe.students.map.with_index { |student, index| student.update(last_name: names[index]) }

      expect(inactive_students.map(&:last_name).join).to eq "ABCMZ"
    end
  end
end
