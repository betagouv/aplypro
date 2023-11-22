# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/api_student"
require "./spec/support/shared/student_mapper"

describe Student::Mappers::Fregata do
  subject(:mapper) { described_class }

  let(:establishment) { create(:establishment, :with_masa_user) }
  let(:normal_payload) { build_list(:fregata_student, 2) }

  it_behaves_like "a student mapper" do
    # the following lines to test with real payloads
    # let!(:fixture) { Rails.root.join("mock/data/fregata-students.json").read }
    # let(:normal_payload) { JSON.parse(fixture) }

    let(:normal_payload) { build_list(:fregata_student, 2) }
    let(:irrelevant_mefs_payload) { build_list(:fregata_student, 10, :irrelevant) }
    let(:nil_ine_payload) { normal_payload.push(build(:fregata_student, :no_ine)) }
  end

  it "also grabs the address" do
    mapper.new(normal_payload, establishment).parse!

    expect(Student.all.map(&:missing_address?).uniq).to contain_exactly false
  end

  context "when the student has left the establishment" do
    let(:data) { build_list(:fregata_student, 1, :left_establishment, left_at: 3.days.ago, ine: "test") }

    it "sets the correct end date on the previous schooling" do
      mapper.new(data, establishment).parse!

      expect(Student.find_by(ine: "test").schoolings.last.end_date).to eq 3.days.ago.to_date
    end
  end

  context "when the student has left the class" do
    let(:data) { build_list(:fregata_student, 1, :left_classe, left_classe_at: 4.days.ago, ine: "test") }

    it "sets the correct end date on the previous schooling" do
      mapper.new(data, establishment).parse!

      expect(Student.find_by(ine: "test").schoolings.last.end_date).to eq 4.days.ago.to_date
    end
  end

  context "when there are multiple entries for the same student" do
    subject(:student) { create(:student) }

    let(:data) do
      [
        build(:fregata_student, classe_label: "new class", ine: student.ine),
        build(:fregata_student, :left_classe, ine: student.ine)
      ]
    end

    before { mapper.new(data, establishment).parse! }

    it "parses them correctly" do
      expect(student.schoolings).to have(2).schoolings
    end

    it "parses the correct current one" do
      expect(student.current_schooling.classe.label).to eq "new class"
    end
  end

  context "when a student has already left on the first parse" do
    let(:data) { [build(:fregata_student, :left_establishment)] }

    it "parses the student" do
      expect { mapper.new(data, establishment).parse! }.to change(Student, :count).by(1)
    end

    it "closes the schooling straight away" do
      expect { mapper.new(data, establishment).parse! }.not_to change(Schooling.current, :count)
    end
  end
end
