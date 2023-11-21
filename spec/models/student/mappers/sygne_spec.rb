# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/api_student"
require "./spec/support/shared/student_mapper"

describe Student::Mappers::Sygne do
  it_behaves_like "a student mapper" do
    let(:establishment) { create(:establishment, :with_fim_user) }
    let(:normal_payload) { build_list(:sygne_student, 10, classe: "1MELEC") }
    let(:irrelevant_mefs_payload) { build_list(:sygne_student, 10, codeMef: "-1") }
    let(:nil_ine_payload) { normal_payload.push(build(:sygne_student, :no_ine)) }
    let(:last_ine) { normal_payload.last["ine"] }
    let(:last_student_has_changed_class_payload) do
      normal_payload.dup.tap do |students|
        students.last["classe"] = "some new class"
      end
    end

    # with SYGNE, a known student not present in the payload means they're gone
    let(:last_student_has_left_establishment_payload) { normal_payload.dup.tap(&:pop) }
  end
end
