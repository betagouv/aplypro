# frozen_string_literal: true

require "rails_helper"

require "./mock/apis/factories/api_student"
require "./spec/support/shared/student_mapper"

describe Student::Mappers::Fregata do
  subject(:mapper) { described_class }

  let(:establishment) { create(:establishment, :fregata_provider) }
  let(:uai) { establishment.uai }
  let(:normal_payload) { build_list(:fregata_student, 2) }

  it_behaves_like "a student mapper" do
    let(:normal_payload) { build_list(:fregata_student, 2) }
    let(:irrelevant_mefs_payload) { build_list(:fregata_student, 10, :irrelevant) }
    let(:nil_ine_payload) { normal_payload.push(build(:fregata_student, :no_ine)) }
    let(:faulty_student_payload) { normal_payload.push(build(:fregata_student).except("apprenant")) }
    let(:faulty_classe_payload) { normal_payload.push(build(:fregata_student).except("division")) }
  end

  it "also grabs the address" do
    mapper.new(normal_payload, uai).parse!

    expect(Student.all.map(&:missing_address?).uniq).to contain_exactly false
  end

  context "when the student has left the establishment" do
    let(:data) { build_list(:fregata_student, 1, :left_establishment, left_at: 1.day.ago, ine_value: "test") }

    it "sets the correct end date on the previous schooling" do
      mapper.new(data, uai).parse!
      expect(Student.find_by!(ine: "test").schoolings.last.end_date).to eq 1.day.ago.to_date
    end
  end

  context "when the student has left the class" do
    let(:data) { build_list(:fregata_student, 1, :left_classe, left_classe_at: 1.day.ago, ine_value: "test") }

    it "sets the correct end date on the previous schooling" do
      mapper.new(data, uai).parse!

      expect(Student.find_by!(ine: "test").schoolings.last.end_date).to eq 1.day.ago.to_date
    end

    context "when there was already a previous schooling for this class" do
      let(:previous_data) do
        [
          data.first.deep_dup.tap do |attrs|
            attrs["dateSortieFormation"] = nil
          end
        ]
      end

      before { mapper.new(previous_data, uai).parse! }

      it "updates the end date in place" do
        expect { mapper.new(data, uai).parse! }.to change(Schooling.current, :count).by(-1)
      end
    end

    context "when the schooling is not in the current school year" do
      before { data.first.update(dateEntreeFormation: "#{SchoolYear.current.start_year - 2}-05-05") }

      it "does not update the end date" do
        mapper.new(data, uai).parse!

        expect(Student.find_by!(ine: "test").schoolings.last.end_date).to be_nil
      end
    end
  end

  context "when the student is an apprentice" do
    let(:data) { build_list(:fregata_student, 1, :apprentice) }

    it "updates the schooling status" do
      mapper.new(data, uai).parse!

      expect(Schooling.last).to be_apprentice
    end
  end

  context "when there are multiple entries for the same student" do
    subject(:student) { create(:student) }

    let(:data) do
      [
        build(:fregata_student, classe_label: "new class", ine_value: student.ine),
        build(:fregata_student, :left_classe, ine_value: student.ine)
      ]
    end

    before { mapper.new(data, uai).parse! }

    it "parses them correctly" do
      expect(student.schoolings).to have(2).schoolings
    end

    it "parses the correct current one" do
      expect(student.current_schooling.classe.label).to eq "new class"
    end
  end

  context "when there is a schooling for that classe that was closed" do
    let(:closed_payload) { [build(:fregata_student, :left_establishment, ine_value: "1234")] }
    let(:student) { Student.find_by(ine: "1234") }

    before { mapper.new(closed_payload, uai).parse! }

    it "sets the end_date for closed schoolings" do
      expect(student.schoolings.last.end_date.to_s).to eq closed_payload.last["dateSortieEtablissement"]
    end

    it "reopens the schooling" do
      opened_payload = [build(:fregata_student, ine_value: "1234")]
      mapper.new(opened_payload, uai).parse!

      expect(student.schoolings.last.open?).to be true
    end
  end

  describe "estEN filtering" do
    context "when all students in a class are estEN" do
      let(:data) do
        [
          build(:fregata_student, :national_education, classe_label: "TEST CLASS", ine_value: "1111"),
          build(:fregata_student, :national_education, classe_label: "TEST CLASS", ine_value: "2222")
        ]
      end

      it "does not create the classe" do
        expect { mapper.new(data, uai).parse! }.not_to change(Classe, :count)
      end
    end

    context "when some students in a class are estEN" do
      let(:data) do
        [
          build(:fregata_student, classe_label: "MIXED CLASS", ine_value: "1111"),
          build(:fregata_student, :national_education, classe_label: "MIXED CLASS", ine_value: "2222"),
          build(:fregata_student, classe_label: "MIXED CLASS", ine_value: "3333")
        ]
      end

      it "only creates non-estEN students" do
        mapper.new(data, uai).parse!
        expect(Student.pluck(:ine)).to contain_exactly("1111", "3333")
      end
    end
  end
end
