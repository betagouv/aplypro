# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/api_student"
require "./spec/support/shared/student_mapper"

describe Student::Mappers::Fregata do
  subject(:mapper) { described_class }

  it_behaves_like "a student mapper", true do
    let(:establishment) { create(:establishment, :with_masa_user) }
    let(:data) { normal_payload }

    # the following lines to test with some massive staging payloads
    # let!(:fixture) { Rails.root.join("mock/data/fregata-students.json").read }
    # let(:data) { JSON.parse(fixture) }

    let(:normal_payload) { build_list(:fregata_student, 2) }
    let(:empty_payload) { build_list(:fregata_student, 0) }
    let(:student_ine) { normal_payload.first["apprenant"]["ine"] }
    let(:nil_ine_payload) { normal_payload.push(build(:fregata_student, :no_ine)) }
    let(:irrelevant_mefs_payload) { build_list(:fregata_student, 10, :irrelevant) }
  end
end
