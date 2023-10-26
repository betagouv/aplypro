# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/api_student"
require "./spec/support/shared/student_mapper"

describe Student::Mappers::Sygne do
  subject(:mapper) { described_class }

  it_behaves_like "a student mapper" do
    let(:establishment) { create(:establishment, :with_fim_user) }
    let(:data) { normal_payload }
    let(:normal_payload) { build_list(:sygne_student, 10) }
    let(:empty_payload) { build_list(:sygne_student, 0) }
    let(:student_ine) { normal_payload.first["ine"] }
    let(:irrelevant_mefs_payload) { build_list(:sygne_student, 10, codeMef: "-1") }
    let(:nil_ine_payload) { normal_payload.push(build(:sygne_student, :no_ine)) }
    let(:gone_student_payload) { build_list(:sygne_student, 1, :gone, ine: student_ine) }
    let(:changed_class_student_payload) { build_list(:sygne_student, 1, ine: student_ine, classe: "NEW") }
  end
end
