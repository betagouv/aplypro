# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/api_student"
require "./spec/support/shared/student_mapper"

describe Student::Mappers::Sygne do
  subject(:mapper) { described_class }

  let(:etab) { create(:establishment, :with_fim_user) }
  let(:data) { build_list(:sygne_student, 10) }
  let(:irrelevant) { build_list(:sygne_student, 10, codeMef: "-1") }

  it_behaves_like "a student mapper"
end
