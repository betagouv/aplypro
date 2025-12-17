# frozen_string_literal: true

require "rails_helper"

require "./mock/apis/factories/api_student"
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
    expect { mapper.new(normal_payload, establishment.uai).parse! }.to change(Schooling.where(status: 0), :count)
  end

  context "when a student has invalid data" do
    let(:data) do
      normal_payload.tap do |payload|
        payload.first["ine"] = "123456"
        payload.first["date_début"] = "2025-09-03"
        payload.first["date_fin"] = "2025-09-01"
      end
    end

    it "ignores it" do
      mapper.new(data, uai).parse!

      expect(Student.find_by(ine: "123456").schoolings).to be_empty
    end

    it "does not raise an error" do
      expect { mapper.new(data, uai).parse! }.not_to raise_error
    end
  end
end
