# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/api_student"
require "./spec/support/shared/student_mapper"

describe Student::Mappers::Fregata do
  subject(:mapper) { described_class }

  let(:establishment) { create(:establishment, :with_masa_user) }
  let(:normal_payload) { build_list(:fregata_student, 2, classe_label: "1AGRO") }
  let(:last_ine) { normal_payload.last["apprenant"]["ine"] }

  it_behaves_like "a student mapper" do
    # the following lines to test with some massive staging payloads
    # let!(:fixture) { Rails.root.join("mock/data/fregata-students.json").read }
    # let(:normal_payload) { JSON.parse(fixture) }

    let(:irrelevant_mefs_payload) { build_list(:fregata_student, 10, :irrelevant) }
    let(:nil_ine_payload) { normal_payload.push(build(:fregata_student, :no_ine)) }
    let(:last_student_has_changed_class_payload) do
      normal_payload.dup << build(:fregata_student, :changed_class, ine: last_ine)
    end

    let(:last_student_has_left_establishment_payload) do
      normal_payload.dup << build(:fregata_student, :left_establishment, ine: last_ine)
    end
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
    let(:data) do
      [
        build(:fregata_student, ine: last_ine),
        build(:fregata_student, :changed_class, ine: last_ine)
      ]
    end

    it "parses them correctly" do
      mapper.new(data, establishment).parse!

      expect(Student.find_by(ine: last_ine).schoolings).to have(2).schoolings
    end
  end

  # NOTE: we need a separate test because SYGNE's "student left" logic
  # implies two calls (one with the student, a subsequent one
  # without), whereas FREGATA can have a student gone straight away,
  # because it is explicitly set in the timestamp attributes for it.
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
