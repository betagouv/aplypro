# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/api_student"
require "./spec/support/shared/student_mapper"

describe Student::Mappers::Fregata do
  subject(:mapper) { described_class }

  let!(:fixture) { Rails.root.join("mock/data/fregata-students.json").read }
  let(:etab) { create(:establishment, :with_masa_principal) }
  let(:data) { JSON.parse(fixture) }

  let(:irrelevant) do
    JSON.parse(fixture).map do |student|
      student["sectionReference"]["codeMef"] = "-123"
      student["division"]["id"] = 456
      student
    end
  end

  it_behaves_like "a student mapper"
end
