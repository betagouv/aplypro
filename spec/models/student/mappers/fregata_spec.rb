# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/api_student"
require "./spec/support/shared/student_mapper"

describe Student::Mappers::Fregata do
  subject(:mapper) { described_class }

  let(:establishment) { create(:establishment, :with_masa_user) }
  let(:data) { normal_payload }
  let(:normal_payload) { build_list(:fregata_student, 2) }
  let(:student_ine) { normal_payload.first["apprenant"]["ine"] }

  it_behaves_like "a student mapper" do
    let(:establishment) { create(:establishment, :with_masa_user) }
    let(:data) { normal_payload }

    # the following lines to test with some massive staging payloads
    # let!(:fixture) { Rails.root.join("mock/data/fregata-students.json").read }
    # let(:data) { JSON.parse(fixture) }

    let(:empty_payload) { build_list(:fregata_student, 0) }
    let(:nil_ine_payload) { normal_payload.push(build(:fregata_student, :no_ine)) }
    let(:irrelevant_mefs_payload) { build_list(:fregata_student, 10, :irrelevant) }
    let(:gone_student_payload) { build_list(:fregata_student, 1, :gone, ine: student_ine) }
    let(:changed_class_student_payload) { build_list(:fregata_student, 1, ine: student_ine, classe_label: "NEW") }
  end

  it "also grabs the address" do
    mapper.new(data, establishment).parse!

    expect(Student.find_by(ine: student_ine)).not_to be_missing_address
  end
end
