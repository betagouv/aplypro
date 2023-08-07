# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/api_student"
require "./spec/support/shared/student_mapper"

describe Student::Mappers::Fregata do
  subject(:mapper) { described_class }

  let(:etab) { create(:establishment, :with_masa_principal) }
  let(:data) { JSON.parse(Rails.root.join("mock/data/fregata-students.json").read) }

  it_behaves_like "a student mapper"
end
