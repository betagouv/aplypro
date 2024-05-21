# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/api_student"
require "./spec/support/shared/student_mapper"

describe Student::Mappers::CSV do
  subject(:mapper) { described_class }

  let(:normal_payload) { CSV.parse(fixture, col_sep: ";", headers: true) }
  let(:establishment) { create(:establishment) }
  let(:uai) { establishment.uai }
  let(:fixture) { Rails.root.join("spec/services/csv_importer_fixture.csv").read }

  it_behaves_like "a student mapper" do
    let(:nil_ine_payload) { normal_payload.tap { |payload| payload.first["ine"] = "" } }
    let(:irrelevant_mefs_payload) { normal_payload.tap { |payload| payload.first["mef_code"] = "ABC" } }
    let(:faulty_student_payload) { normal_payload.tap { |payload| payload.delete("mef_code") } }
    let(:faulty_classe_payload) { normal_payload.tap { |payload| payload.delete("classe_label") } }
  end

  it "assumes students have the right status" do
    expect { mapper.new(normal_payload, establishment.uai).parse! }.to change(Schooling.student, :count)
  end
end
